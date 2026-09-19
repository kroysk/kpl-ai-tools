# Verify install -Refresh preserves customizations and updates kit scaffold.
# Run from kit root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-kpl-refresh.ps1

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
$failed = 0

function Assert-True($Cond, [string]$Msg) {
    if (-not $Cond) {
        Write-Host "FAIL: $Msg" -ForegroundColor Red
        $script:failed++
    } else {
        Write-Host "OK   $Msg"
    }
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("kpl-refresh-test-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work -Force | Out-Null

try {
    $target = Join-Path $work "project"
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    # Fresh install first
    & (Join-Path $KitRoot "scripts\install.ps1") -Target $target
    Assert-True (Test-Path (Join-Path $target "AGENTS.md")) "fresh install creates AGENTS.md"
    Assert-True (Test-Path (Join-Path $target "agents\io-policy.json")) "fresh install copies io-policy"

    # Customize preserve targets
    $stackMarker = "CUSTOM_STACK_MARKER_42"
    $cpMarker = "CUSTOM_CONTROL_PLANE_99"
    $hookMarker = "CUSTOM_STACK_HOOKS_77"
    $featureMarker = "CUSTOM_FEATURE_KEEP"
    $memMarker = "CUSTOM_MEMORY_INDEX"
    $ocMarker = "CUSTOM_OPENCODE_JSON"
    $bootMarker = "ORIGINAL_BOOTSTRAP_LINE"

    Set-Content -LiteralPath (Join-Path $target "specs\stack.md") -Value "# Stack`n$stackMarker" -Encoding utf8
    Set-Content -LiteralPath (Join-Path $target "agents\CONTROL_PLANE.md") -Value "# CP`n$cpMarker" -Encoding utf8
    Set-Content -LiteralPath (Join-Path $target "agents\skills\architecture-mentor\stack-hooks.md") -Value "# Hooks`n$hookMarker" -Encoding utf8
    New-Item -ItemType Directory -Path (Join-Path $target ".cursor\skills\architecture-mentor") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target ".cursor\skills\architecture-mentor\stack-hooks.md") -Value "# CursorHooks`n$hookMarker" -Encoding utf8

    $featDir = Join-Path $target "specs\features\demo-feat"
    New-Item -ItemType Directory -Path $featDir -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $featDir "discovery.md") -Value $featureMarker -Encoding utf8

    Set-Content -LiteralPath (Join-Path $target "memory\INDEX.md") -Value "# Index`n$memMarker" -Encoding utf8
    Set-Content -LiteralPath (Join-Path $target "memory\cards\my-lesson.md") -Value "# Lesson keep" -Encoding utf8

    Set-Content -LiteralPath (Join-Path $target ".opencode\opencode.json") -Value ('{"$schema":"' + $ocMarker + '"}') -Encoding utf8

    $boot = Join-Path $target "specs\features\_bootstrap\README.md"
    Set-Content -LiteralPath $boot -Value "# Bootstrap`n`n$bootMarker" -Encoding utf8

    # User Cursor hook that must survive merge
    New-Item -ItemType Directory -Path (Join-Path $target ".cursor") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target ".cursor\hooks.json") -Value (@{
        version = 1
        hooks   = @{
            preToolUse = @(@{ command = "user-keep.ps1"; matcher = "Write" })
        }
    } | ConvertTo-Json -Depth 6) -Encoding utf8

    # Contract README customized
    Set-Content -LiteralPath (Join-Path $target "specs\contract\README.md") -Value "# Contract`nCUSTOM_CONTRACT" -Encoding utf8

    # Refresh
    & (Join-Path $KitRoot "scripts\install.ps1") -Refresh -Target $target

    Assert-True ((Get-Content (Join-Path $target "specs\stack.md") -Raw) -match $stackMarker) "stack.md preserved"
    Assert-True ((Get-Content (Join-Path $target "agents\CONTROL_PLANE.md") -Raw) -match $cpMarker) "CONTROL_PLANE preserved"
    Assert-True ((Get-Content (Join-Path $target "agents\skills\architecture-mentor\stack-hooks.md") -Raw) -match $hookMarker) "agents stack-hooks preserved"
    Assert-True ((Get-Content (Join-Path $target ".cursor\skills\architecture-mentor\stack-hooks.md") -Raw) -match $hookMarker) "cursor stack-hooks preserved"
    Assert-True ((Get-Content (Join-Path $featDir "discovery.md") -Raw) -match $featureMarker) "specs/features preserved"
    Assert-True ((Get-Content (Join-Path $target "memory\INDEX.md") -Raw) -match $memMarker) "memory INDEX preserved"
    Assert-True (Test-Path (Join-Path $target "memory\cards\my-lesson.md")) "memory card preserved"
    Assert-True ((Get-Content (Join-Path $target ".opencode\opencode.json") -Raw) -match $ocMarker) "opencode.json preserved"
    Assert-True ((Get-Content (Join-Path $target "specs\contract\README.md") -Raw) -match "CUSTOM_CONTRACT") "contract README preserved"

    $bootText = Get-Content $boot -Raw
    Assert-True ($bootText -match $bootMarker) "bootstrap original kept"
    Assert-True ($bootText -match "Refreshed") "bootstrap append Refreshed"

    Assert-True (Test-Path (Join-Path $target "agents\skills\bulk-read\SKILL.md")) "bulk-read skill present after refresh"
    Assert-True (Test-Path (Join-Path $target "agents\io-policy.json")) "io-policy present after refresh"
    Assert-True (Test-Path (Join-Path $target ".opencode\plugins\kpl-bulk-read.js")) "opencode plugin present"

    $cursorHooks = Get-Content (Join-Path $target ".cursor\hooks.json") -Raw
    Assert-True ($cursorHooks -match "user-keep") "user Cursor hook preserved"
    Assert-True ($cursorHooks -match "kpl-check-read") "KPL hook merged on refresh"
}
finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}

if ($failed -gt 0) {
    Write-Host "`n$failed check(s) failed" -ForegroundColor Red
    exit 1
}
Write-Host "`nAll refresh checks passed"
exit 0
