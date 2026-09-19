# Install Kephale AI Toolkit (kpl-ai-tools) SDD control plane into a project.
# Windows PowerShell. Merge-safe: never deletes specs/features/**; does not touch src/ app/.
#
# Usage (from a local clone):
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\install.ps1 [target-dir]
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
    [string]$Target = "."
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

Write-Host "==> Kephale AI Toolkit install"
Write-Host "    repo: $RepoUrl @ $Ref"
Write-Host "    target: $Target"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required. Install Git for Windows and retry."
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null
$Target = (Resolve-Path $Target).Path

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

Copy-Item -Force (Join-Path $Templates "AGENTS.md") (Join-Path $Target "AGENTS.md")
Copy-Item -Force (Join-Path $Templates "CLAUDE.md") (Join-Path $Target "CLAUDE.md")

Merge-Dir (Join-Path $Templates "agents") (Join-Path $Target "agents")

$specs = Join-Path $Target "specs"
New-Item -ItemType Directory -Path $specs -Force | Out-Null
foreach ($item in @("README.md", "SKILLS.md", "stack.md")) {
    $src = Join-Path $Templates "specs\$item"
    if (Test-Path $src) {
        Copy-Item -Force $src (Join-Path $specs $item)
    }
}
Merge-Dir (Join-Path $Templates "specs\contract") (Join-Path $specs "contract")
Merge-Dir (Join-Path $Templates "specs\_templates") (Join-Path $specs "_templates")

$bootstrap = Join-Path $specs "features\_bootstrap"
New-Item -ItemType Directory -Path $bootstrap -Force | Out-Null
$date = Get-Date -Format "yyyy-MM-dd"
@"
# Bootstrap

Installed by Kephale AI Toolkit scripts/install.ps1 on $date

Source: $RepoUrl @ $Ref
"@ | Set-Content -Path (Join-Path $bootstrap "README.md") -Encoding utf8

Merge-Dir (Join-Path $Templates "memory") (Join-Path $Target "memory")

Merge-Dir (Join-Path $Templates "tool-stubs\cursor") (Join-Path $Target ".cursor")
Merge-Dir (Join-Path $Templates "tool-stubs\claude") (Join-Path $Target ".claude")

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
Write-Host "Done. Control plane installed at:"
Write-Host "  $Target"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Open this project in Cursor / Claude Code / OpenCode"
Write-Host "  2. Fill specs/stack.md for your stack"
Write-Host "  3. Start with skill: feature-discovery"
Write-Host ""
Write-Host "Did not modify application source (src/, app/, etc.)."
