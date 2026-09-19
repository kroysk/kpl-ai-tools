# Verify token-I/O hook allow/deny and merge-safe init behavior.
# Run from kit root:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-kpl-io-policy.ps1

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
$hook = Join-Path $KitRoot "templates\agents\hooks\kpl-check-read.ps1"
$failed = 0

function Assert-True($Cond, [string]$Msg) {
    if (-not $Cond) {
        Write-Host "FAIL: $Msg" -ForegroundColor Red
        $script:failed++
    } else {
        Write-Host "OK   $Msg"
    }
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ("kpl-io-test-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $work -Force | Out-Null
try {
    New-Item -ItemType Directory -Path (Join-Path $work "agents\hooks") -Force | Out-Null
    Copy-Item (Join-Path $KitRoot "templates\agents\io-policy.json") (Join-Path $work "agents\io-policy.json")
    Copy-Item $hook (Join-Path $work "agents\hooks\kpl-check-read.ps1")
    Set-Content -Path (Join-Path $work "AGENTS.md") -Value "# test" -Encoding utf8

    $big = Join-Path $work "big.cs"
    $lines = 1..600 | ForEach-Object { "line $_" }
    Set-Content -LiteralPath $big -Value $lines -Encoding utf8

    $small = Join-Path $work "small.cs"
    Set-Content -LiteralPath $small -Value (1..10 | ForEach-Object { "line $_" }) -Encoding utf8

    Push-Location $work
    try {
        function Invoke-Hook([string]$Json, [hashtable]$EnvExtra) {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "powershell"
            $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$hook`""
            $psi.WorkingDirectory = $work
            $psi.RedirectStandardInput = $true
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            if ($EnvExtra) {
                foreach ($k in $EnvExtra.Keys) {
                    if ($psi.EnvironmentVariables.ContainsKey($k)) {
                        $psi.EnvironmentVariables[$k] = "$($EnvExtra[$k])"
                    } else {
                        $psi.EnvironmentVariables.Add($k, "$($EnvExtra[$k])")
                    }
                }
            }
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $psi
            [void]$p.Start()
            $p.StandardInput.Write($Json)
            $p.StandardInput.Close()
            $out = $p.StandardOutput.ReadToEnd()
            $p.WaitForExit()
            return [pscustomobject]@{ ExitCode = $p.ExitCode; Output = $out.Trim() }
        }

        $deny = Invoke-Hook (@{ tool_name = "Read"; tool_input = @{ file_path = "big.cs" } } | ConvertTo-Json -Compress)
        Assert-True ($deny.ExitCode -eq 2) "600-line full Read is denied (exit $($deny.ExitCode))"
        Assert-True ($deny.Output -match '"permission"\s*:\s*"deny"') "deny JSON: $($deny.Output)"

        $allowLimit = Invoke-Hook (@{ tool_name = "Read"; tool_input = @{ file_path = "big.cs"; offset = 1; limit = 40 } } | ConvertTo-Json -Compress)
        Assert-True ($allowLimit.ExitCode -eq 0 -and $allowLimit.Output -match '"permission"\s*:\s*"allow"') "offset/limit Read is allowed"

        $allowSmall = Invoke-Hook (@{ tool_name = "Read"; tool_input = @{ file_path = "small.cs" } } | ConvertTo-Json -Compress)
        Assert-True ($allowSmall.ExitCode -eq 0 -and $allowSmall.Output -match '"permission"\s*:\s*"allow"') "small file Read is allowed"

        $allowEnv = Invoke-Hook (@{ tool_name = "Read"; tool_input = @{ file_path = "big.cs" } } | ConvertTo-Json -Compress) @{ KPL_READ_MIN_LINES = "0" }
        Assert-True ($allowEnv.ExitCode -eq 0 -and $allowEnv.Output -match '"permission"\s*:\s*"allow"') "KPL_READ_MIN_LINES=0 allows full Read"

        $allowPipe = Invoke-Hook (@{ tool_name = "Bash"; tool_input = @{ command = "cat big.cs | grep line" } } | ConvertTo-Json -Compress)
        Assert-True ($allowPipe.ExitCode -eq 0 -and $allowPipe.Output -match '"permission"\s*:\s*"allow"') "cat | grep is allowed"

        $denyCat = Invoke-Hook (@{ tool_name = "Bash"; tool_input = @{ command = "cat big.cs" } } | ConvertTo-Json -Compress)
        Assert-True ($denyCat.ExitCode -eq 2) "cat of large file is denied (exit $($denyCat.ExitCode))"
    }
    finally {
        Pop-Location
    }

    # Merge-safe: existing user hook + settings survive
    $target = Join-Path $work "target"
    New-Item -ItemType Directory -Path (Join-Path $target ".cursor") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $target ".claude") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $target ".opencode") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target ".cursor\hooks.json") -Value (@{
        version = 1
        hooks   = @{
            preToolUse = @(@{ command = "user-keep.ps1"; matcher = "Write" })
        }
    } | ConvertTo-Json -Depth 6) -Encoding utf8
    Set-Content -LiteralPath (Join-Path $target ".claude\settings.json") -Value (@{
        permissions = @{ allow = @("Bash") }
        hooks       = @{
            PreToolUse = @(@{ matcher = "Write"; hooks = @(@{ type = "command"; command = "user-keep.sh" }) })
        }
    } | ConvertTo-Json -Depth 8) -Encoding utf8
    Set-Content -LiteralPath (Join-Path $target ".opencode\opencode.json") -Value '{"$schema":"keep-me"}' -Encoding utf8

    & (Join-Path $KitRoot "scripts\merge-kpl-io-hooks.ps1") -Target $target

    $cursor = Get-Content (Join-Path $target ".cursor\hooks.json") -Raw
    Assert-True ($cursor -match "user-keep") "Cursor merge keeps user hook"
    Assert-True ($cursor -match "kpl-check-read") "Cursor merge adds KPL hook"
    $cursorObj = $cursor | ConvertFrom-Json
    $preCount = @($cursorObj.hooks.preToolUse).Count
    Assert-True ($preCount -ge 2) "Cursor preToolUse stays an array (count=$preCount)"

    $claude = Get-Content (Join-Path $target ".claude\settings.json") -Raw
    Assert-True ($claude -match "user-keep") "Claude merge keeps user hook"
    Assert-True ($claude -match "kpl-check-read") "Claude merge adds KPL hook"
    Assert-True ($claude -match "allow") "Claude merge keeps unrelated keys"

    $oc = Get-Content (Join-Path $target ".opencode\opencode.json") -Raw
    Assert-True ($oc -match "keep-me") "opencode.json left untouched by merge"
}
finally {
    Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
}

if ($failed -gt 0) {
    Write-Host "`n$failed check(s) failed" -ForegroundColor Red
    exit 1
}
Write-Host "`nAll token-I/O checks passed"
exit 0
