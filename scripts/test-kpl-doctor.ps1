# Verify kpl-doctor: fresh install PASSes with WARN on stack.md; missing skill → FAIL.
# Run from kit root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-kpl-doctor.ps1

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

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("kpl-doctor-test-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work -Force | Out-Null

try {
    $target = Join-Path $work "project"
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    & (Join-Path $KitRoot "scripts\install.ps1") -Target $target
    Assert-True (Test-Path (Join-Path $target ".kpl\agents\kpl-kit.json")) "install writes kpl-kit.json"
    Assert-True ((Get-Content (Join-Path $target "AGENTS.md") -Raw) -match "kpl:user:start") "AGENTS.md has kpl:user markers"

    $doctor = Join-Path $KitRoot "scripts\kpl-doctor.ps1"
    & $doctor -Target $target
    $exitWarn = $LASTEXITCODE
    Assert-True ($exitWarn -eq 0) "fresh install doctor exits 0 (WARN on unfilled stack allowed)"

    # Remove a skill that SKILLS.md lists → FAIL
    $bulk = Join-Path $target ".kpl\agents\skills\bulk-read"
    Remove-Item -Recurse -Force $bulk
    & $doctor -Target $target
    $exitFail = $LASTEXITCODE
    Assert-True ($exitFail -ne 0) "doctor exits non-zero when a listed skill is missing"
}
finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}

if ($failed -gt 0) {
    Write-Host "`n$failed check(s) failed" -ForegroundColor Red
    exit 1
}
Write-Host "`nAll doctor checks passed"
exit 0
