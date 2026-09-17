# Sync canonical agents/skills → tool-stubs for Cursor, Claude, OpenCode.
# Run from kit root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-tool-skills.ps1

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
$Canon = Join-Path $KitRoot "templates\agents\skills"
$Targets = @(
    (Join-Path $KitRoot "templates\tool-stubs\cursor\skills"),
    (Join-Path $KitRoot "templates\tool-stubs\claude\skills"),
    (Join-Path $KitRoot "templates\tool-stubs\opencode\skills")
)

if (-not (Test-Path $Canon)) {
    throw "Canonical skills not found: $Canon"
}

foreach ($dest in $Targets) {
    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path (Join-Path $Canon "*") -Destination $dest -Recurse -Force
    Write-Host "Synced → $dest"
}

Write-Host "Done. Canon: $Canon"
