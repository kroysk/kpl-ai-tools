# Install Kephale AI Toolkit (kpl-ai-tools) SDD control plane into a project.
# Windows PowerShell. Merge-safe: never deletes specs/features/**; does not touch src/ app/.
#
# Usage (from a local clone):
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install.ps1 [target-dir]
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install.ps1 -Refresh [target-dir]
#
# Usage (from GitHub, in your project folder):
#   $env:KPL_REPO_URL = "https://github.com/kroysk/kpl-ai-tools.git"
#   irm https://raw.githubusercontent.com/kroysk/kpl-ai-tools/main/scripts/install.ps1 | iex
#
# Env:
#   KPL_REPO_URL  Git URL (default: https://github.com/kroysk/kpl-ai-tools.git)
#   KPL_REF       Branch or tag (default: main)

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target = ".",
    [switch]$Refresh
)

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:KPL_REPO_URL) { $env:KPL_REPO_URL } else { "https://github.com/kroysk/kpl-ai-tools.git" }
$Ref = if ($env:KPL_REF) { $env:KPL_REF } else { "main" }

function Merge-Dir {
    param([string]$Src, [string]$Dest)
    if (-not (Test-Path $Src)) { throw "Missing source: $Src" }
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    Copy-Item -Path (Join-Path $Src "*") -Destination $Dest -Recurse -Force
}

function Copy-FileForce([string]$Src, [string]$Dest) {
    $dir = Split-Path -Parent $Dest
    if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -Force $Src $Dest
}

function Copy-FileIfMissing([string]$Src, [string]$Dest) {
    if (Test-Path -LiteralPath $Dest) { return }
    Copy-FileForce $Src $Dest
}

function Backup-IfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    }
    return $null
}

function Restore-IfBacked([string]$Path, $Content) {
    if ($null -eq $Content) { return }
    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8 -NoNewline
}

function Merge-MemoryRefresh([string]$Src, [string]$Dest) {
    # Refresh: add missing template ADR only; never overwrite INDEX or existing cards.
    New-Item -ItemType Directory -Path (Join-Path $Dest "cards") -Force | Out-Null
    $indexSrc = Join-Path $Src "INDEX.md"
    $indexDest = Join-Path $Dest "INDEX.md"
    if ((Test-Path $indexSrc) -and -not (Test-Path $indexDest)) {
        Copy-FileForce $indexSrc $indexDest
    }
    $tplSrc = Join-Path $Src "cards\_template-adr.md"
    $tplDest = Join-Path $Dest "cards\_template-adr.md"
    if ((Test-Path $tplSrc) -and -not (Test-Path $tplDest)) {
        Copy-FileForce $tplSrc $tplDest
    }
}

function Merge-CursorPackRefresh([string]$Src, [string]$Dest) {
    # Overwrite KPL skills + kpl-*.mdc rules only; leave other .cursor files alone.
    $skillsSrc = Join-Path $Src "skills"
    if (Test-Path $skillsSrc) {
        Merge-Dir $skillsSrc (Join-Path $Dest "skills")
    }
    $rulesSrc = Join-Path $Src "rules"
    if (Test-Path $rulesSrc) {
        $rulesDest = Join-Path $Dest "rules"
        New-Item -ItemType Directory -Path $rulesDest -Force | Out-Null
        Get-ChildItem -LiteralPath $rulesSrc -Filter "kpl-*.mdc" -File | ForEach-Object {
            Copy-Item -Force $_.FullName (Join-Path $rulesDest $_.Name)
        }
        # Also copy other known KPL rule files from templates (endpoint, security, designer)
        Get-ChildItem -LiteralPath $rulesSrc -Filter "*.mdc" -File | ForEach-Object {
            Copy-Item -Force $_.FullName (Join-Path $rulesDest $_.Name)
        }
    }
}

function Merge-ClaudePackRefresh([string]$Src, [string]$Dest) {
    $skillsSrc = Join-Path $Src "skills"
    if (Test-Path $skillsSrc) {
        Merge-Dir $skillsSrc (Join-Path $Dest "skills")
    }
}

$modeLabel = if ($Refresh) { "refresh" } else { "install" }
Write-Host "==> Kephale AI Toolkit $modeLabel"
Write-Host "    repo: $RepoUrl @ $Ref"
Write-Host "    target: $Target"
if ($Refresh) { Write-Host "    mode: refresh (preserve stack/CONTROL_PLANE/features/memory cards)" }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required. Install Git for Windows and retry."
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null
$Target = (Resolve-Path $Target).Path

if ($Refresh) {
    if (-not (Test-Path (Join-Path $Target "AGENTS.md")) -or -not (Test-Path (Join-Path $Target "agents"))) {
        throw "Refresh requires an existing control plane (AGENTS.md + agents/). Use install without -Refresh for first-time setup."
    }
}

$KitRoot = $null
$Cleanup = $null

# Local kit if this script lives inside kpl-ai-tools
if ($PSScriptRoot) {
    $candidate = Split-Path -Parent $PSScriptRoot
    if ((Test-Path (Join-Path $candidate "templates\agents")) -and (Test-Path (Join-Path $candidate "templates\tool-stubs"))) {
        $KitRoot = $candidate
        Write-Host "    kit: local $KitRoot"
    }
}

if (-not $KitRoot) {
    $Cleanup = Join-Path ([System.IO.Path]::GetTempPath()) ("kpl-ai-tools-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $Cleanup -Force | Out-Null
    $clonePath = Join-Path $Cleanup "kpl-ai-tools"
    Write-Host "    kit: cloning into $clonePath"
    & git clone --depth 1 --branch $Ref $RepoUrl $clonePath
    if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
    $KitRoot = $clonePath
}

$Templates = Join-Path $KitRoot "templates"
if (-not (Test-Path (Join-Path $Templates "agents"))) {
    throw "templates missing in kit: $Templates"
}

# Backup preserve paths before agents/skill merges (refresh only)
$bakControl = $null
$bakStackHooks = @{}
if ($Refresh) {
    $bakControl = Backup-IfExists (Join-Path $Target "agents\CONTROL_PLANE.md")
    $hookPaths = @(
        (Join-Path $Target "agents\skills\architecture-mentor\stack-hooks.md"),
        (Join-Path $Target ".cursor\skills\architecture-mentor\stack-hooks.md"),
        (Join-Path $Target ".claude\skills\architecture-mentor\stack-hooks.md"),
        (Join-Path $Target ".opencode\skills\architecture-mentor\stack-hooks.md")
    )
    foreach ($hp in $hookPaths) {
        $bakStackHooks[$hp] = Backup-IfExists $hp
    }
}

Copy-Item -Force (Join-Path $Templates "AGENTS.md") (Join-Path $Target "AGENTS.md")
Copy-Item -Force (Join-Path $Templates "CLAUDE.md") (Join-Path $Target "CLAUDE.md")

Merge-Dir (Join-Path $Templates "agents") (Join-Path $Target "agents")

if ($Refresh -and $null -ne $bakControl) {
    Restore-IfBacked (Join-Path $Target "agents\CONTROL_PLANE.md") $bakControl
}

$specs = Join-Path $Target "specs"
New-Item -ItemType Directory -Path $specs -Force | Out-Null

foreach ($item in @("README.md", "SKILLS.md")) {
    $src = Join-Path $Templates "specs\$item"
    if (Test-Path $src) {
        Copy-Item -Force $src (Join-Path $specs $item)
    }
}

$stackSrc = Join-Path $Templates "specs\stack.md"
$stackDest = Join-Path $specs "stack.md"
if (Test-Path $stackSrc) {
    if ($Refresh) {
        Copy-FileIfMissing $stackSrc $stackDest
    } else {
        Copy-Item -Force $stackSrc $stackDest
    }
}

$contractSrc = Join-Path $Templates "specs\contract"
$contractDest = Join-Path $specs "contract"
if (Test-Path $contractSrc) {
    if ($Refresh) {
        New-Item -ItemType Directory -Path $contractDest -Force | Out-Null
        $contractReadmeSrc = Join-Path $contractSrc "README.md"
        $contractReadmeDest = Join-Path $contractDest "README.md"
        if (Test-Path $contractReadmeSrc) {
            Copy-FileIfMissing $contractReadmeSrc $contractReadmeDest
        }
        Get-ChildItem -LiteralPath $contractSrc -File | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
            Copy-Item -Force $_.FullName (Join-Path $contractDest $_.Name)
        }
    } else {
        Merge-Dir $contractSrc $contractDest
    }
}

Merge-Dir (Join-Path $Templates "specs\_templates") (Join-Path $specs "_templates")

$bootstrap = Join-Path $specs "features\_bootstrap"
New-Item -ItemType Directory -Path $bootstrap -Force | Out-Null
$bootstrapReadme = Join-Path $bootstrap "README.md"
$date = Get-Date -Format "yyyy-MM-dd"
if ($Refresh -and (Test-Path $bootstrapReadme)) {
    $append = @"

## Refreshed $date

Refreshed by Kephale AI Toolkit scripts/install.ps1 -Refresh

Source: $RepoUrl @ $Ref
"@
    Add-Content -LiteralPath $bootstrapReadme -Value $append -Encoding utf8
} else {
    @"
# Bootstrap

Installed by Kephale AI Toolkit scripts/install.ps1 on $date

Source: $RepoUrl @ $Ref
"@ | Set-Content -Path $bootstrapReadme -Encoding utf8
}

$memorySrc = Join-Path $Templates "memory"
$memoryDest = Join-Path $Target "memory"
if (Test-Path $memorySrc) {
    if ($Refresh) {
        Merge-MemoryRefresh $memorySrc $memoryDest
    } else {
        Merge-Dir $memorySrc $memoryDest
    }
}

$cursorSrc = Join-Path $Templates "tool-stubs\cursor"
$claudeSrc = Join-Path $Templates "tool-stubs\claude"
if ($Refresh) {
    Merge-CursorPackRefresh $cursorSrc (Join-Path $Target ".cursor")
    Merge-ClaudePackRefresh $claudeSrc (Join-Path $Target ".claude")
} else {
    Merge-Dir $cursorSrc (Join-Path $Target ".cursor")
    Merge-Dir $claudeSrc (Join-Path $Target ".claude")
}

$opencode = Join-Path $Target ".opencode"
New-Item -ItemType Directory -Path $opencode -Force | Out-Null
Merge-Dir (Join-Path $Templates "tool-stubs\opencode\skills") (Join-Path $opencode "skills")
$ocPlugins = Join-Path $Templates "tool-stubs\opencode\plugins"
if (Test-Path $ocPlugins) {
    Merge-Dir $ocPlugins (Join-Path $opencode "plugins")
}
$ocJsonSrc = Join-Path $Templates "tool-stubs\opencode\opencode.json"
$ocJsonDest = Join-Path $opencode "opencode.json"
if ((Test-Path $ocJsonSrc) -and -not (Test-Path $ocJsonDest)) {
    Copy-Item -Force $ocJsonSrc $ocJsonDest
}

# Restore customized stack-hooks after skill pack overwrite
if ($Refresh) {
    foreach ($hp in $bakStackHooks.Keys) {
        Restore-IfBacked $hp $bakStackHooks[$hp]
    }
}

$mergeHooks = Join-Path $KitRoot "scripts\merge-kpl-io-hooks.ps1"
if (Test-Path $mergeHooks) {
    & $mergeHooks -Target $Target
}

$practices = Join-Path $KitRoot "practices"
if (Test-Path $practices) {
    Merge-Dir $practices (Join-Path $Target "agents\practices")
}

if ($Cleanup) {
    Remove-Item -Recurse -Force $Cleanup
}

Write-Host ""
Write-Host "Done. Control plane ${modeLabel}ed at:"
Write-Host "  $Target"
Write-Host ""
if ($Refresh) {
    Write-Host "Preserved: specs/features/**, stack.md, contract/README.md, CONTROL_PLANE,"
    Write-Host "  stack-hooks.md, memory INDEX/cards, opencode.json; hooks merged."
    Write-Host "Updated: AGENTS/CLAUDE, agents skills/rules/hooks, tool skill packs, token-io."
} else {
    Write-Host "Next:"
    Write-Host "  1. Open this project in Cursor / Claude Code / OpenCode"
    Write-Host "  2. Fill specs/stack.md for your stack"
    Write-Host "  3. Start with skill: feature-discovery"
}
Write-Host ""
Write-Host "Did not modify application source (src/, app/, etc.)."
