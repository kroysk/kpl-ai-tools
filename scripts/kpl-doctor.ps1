# Read-only health check for a KPL control plane in a target project.
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/kpl-doctor.ps1 [-Target <dir>]
# Exit 0 if no FAIL (WARN allowed). Exit 1 if any FAIL. Writes nothing to the target.

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"
$Target = (Resolve-Path $Target).Path
$fails = New-Object System.Collections.Generic.List[string]
$warns = New-Object System.Collections.Generic.List[string]

function Add-Fail([string]$Msg) { $script:fails.Add($Msg) | Out-Null }
function Add-Warn([string]$Msg) { $script:warns.Add($Msg) | Out-Null }

Write-Host "==> kpl-doctor"
Write-Host "    target: $Target"

# kpl-kit.json
$kitJson = Join-Path $Target "agents\kpl-kit.json"
if (-not (Test-Path -LiteralPath $kitJson)) {
    Add-Fail "missing agents/kpl-kit.json"
} else {
    try {
        $stamp = Get-Content -LiteralPath $kitJson -Raw -Encoding UTF8 | ConvertFrom-Json
        foreach ($field in @("kit", "repo", "ref", "installedAt")) {
            $has = $stamp.PSObject.Properties.Name -contains $field
            if (-not $has -or [string]::IsNullOrWhiteSpace([string]$stamp.$field)) {
                Add-Fail "agents/kpl-kit.json missing or empty field: $field"
            }
        }
    } catch {
        Add-Fail "agents/kpl-kit.json is not valid JSON"
    }
}

# Core paths
if (-not (Test-Path -LiteralPath (Join-Path $Target "AGENTS.md"))) { Add-Fail "missing AGENTS.md" }
if (-not (Test-Path -LiteralPath (Join-Path $Target "agents"))) { Add-Fail "missing agents/" }
if (-not (Test-Path -LiteralPath (Join-Path $Target "specs\SKILLS.md"))) { Add-Fail "missing specs/SKILLS.md" }
if (-not (Test-Path -LiteralPath (Join-Path $Target "memory\INDEX.md"))) { Add-Fail "missing memory/INDEX.md" }

# stack.md
$stackPath = Join-Path $Target "specs\stack.md"
if (-not (Test-Path -LiteralPath $stackPath)) {
    Add-Fail "missing specs/stack.md"
} else {
    $stackText = (Get-Content -LiteralPath $stackPath -Raw -Encoding UTF8).Trim()
    $templateish = ($stackText -match '(?i)Filled by `?kpl-sdd-init') -or ($stackText -eq "# Stack") -or ($stackText.Length -lt 40)
    if ($templateish) {
        Add-Warn "specs/stack.md still looks like the unfilled template"
    }
}

# Skills listed in SKILLS.md
$skillsMd = Join-Path $Target "specs\SKILLS.md"
if (Test-Path -LiteralPath $skillsMd) {
    $skillsText = Get-Content -LiteralPath $skillsMd -Raw -Encoding UTF8
    $skillNames = [regex]::Matches($skillsText, '(?m)^\|\s*([a-z0-9-]+)\s*\|') |
        ForEach-Object { $_.Groups[1].Value } |
        Where-Object { $_ -ne "Skill" -and $_ -notmatch '^-+$' }
    foreach ($name in $skillNames) {
        $skillFile = Join-Path $Target "agents\skills\$name\SKILL.md"
        if (-not (Test-Path -LiteralPath $skillFile)) {
            Add-Fail "skill listed in SKILLS.md but missing: agents/skills/$name/SKILL.md"
        }
    }
}

# Tool hooks when tool folders exist
$cursorDir = Join-Path $Target ".cursor"
if (Test-Path -LiteralPath $cursorDir) {
    $hooks = Join-Path $cursorDir "hooks.json"
    if (-not (Test-Path -LiteralPath $hooks)) {
        Add-Fail ".cursor/ present but hooks.json missing"
    } elseif ((Get-Content -LiteralPath $hooks -Raw -Encoding UTF8) -notmatch "kpl-check-read") {
        Add-Fail ".cursor/hooks.json missing kpl-check-read"
    }
}

$claudeDir = Join-Path $Target ".claude"
if (Test-Path -LiteralPath $claudeDir) {
    $settings = Join-Path $claudeDir "settings.json"
    if (-not (Test-Path -LiteralPath $settings)) {
        Add-Fail ".claude/ present but settings.json missing"
    } elseif ((Get-Content -LiteralPath $settings -Raw -Encoding UTF8) -notmatch "kpl-check-read") {
        Add-Fail ".claude/settings.json missing kpl-check-read"
    }
}

$opencodeDir = Join-Path $Target ".opencode"
if (Test-Path -LiteralPath $opencodeDir) {
    $plugin = Join-Path $opencodeDir "plugins\kpl-bulk-read.js"
    if (-not (Test-Path -LiteralPath $plugin)) {
        Add-Fail ".opencode/ present but plugins/kpl-bulk-read.js missing"
    }
}

# AGENTS.md markers
$agentsMd = Join-Path $Target "AGENTS.md"
if (Test-Path -LiteralPath $agentsMd) {
    $agentsText = Get-Content -LiteralPath $agentsMd -Raw -Encoding UTF8
    if ($agentsText -notmatch "kpl:user:start" -or $agentsText -notmatch "kpl:user:end") {
        Add-Fail "AGENTS.md missing kpl:user markers"
    }
}

Write-Host ""
foreach ($w in $warns) { Write-Host "WARN  $w" -ForegroundColor Yellow }
foreach ($f in $fails) { Write-Host "FAIL  $f" -ForegroundColor Red }

if ($fails.Count -eq 0 -and $warns.Count -eq 0) {
    Write-Host "PASS  control plane looks healthy"
} elseif ($fails.Count -eq 0) {
    Write-Host "PASS with WARN ($($warns.Count))"
} else {
    Write-Host "FAILED ($($fails.Count) fail, $($warns.Count) warn)" -ForegroundColor Red
}

if ($fails.Count -gt 0) { exit 1 }
exit 0
