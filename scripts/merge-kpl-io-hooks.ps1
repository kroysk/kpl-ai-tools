# Merge KPL token-I/O hooks into a target without replacing user hook/settings files.
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/merge-kpl-io-hooks.ps1 [-Target <dir>]
#
# Picks powershell vs sh based on the current OS. Marker: kpl-check-read

[CmdletBinding()]
param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

$Target = (Resolve-Path $Target).Path
$IsWin = [System.Environment]::OSVersion.Platform -eq "Win32NT" -or $env:OS -eq "Windows_NT"
$HookCmd = if ($IsWin) {
    "powershell -NoProfile -ExecutionPolicy Bypass -File agents/hooks/kpl-check-read.ps1"
} else {
    "sh agents/hooks/kpl-check-read.sh"
}

function Read-JsonFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return $raw | ConvertFrom-Json
}

function ConvertTo-JsonArray([object[]]$Items) {
    $parts = @()
    foreach ($item in @($Items)) {
        if ($null -eq $item) { continue }
        $parts += ($item | ConvertTo-Json -Depth 8 -Compress)
    }
    if ($parts.Count -eq 0) { return "[]" }
    return "[" + ($parts -join ",") + "]"
}

function Write-JsonFile([string]$Path, $Obj) {
    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $json = $Obj | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath $Path -Value $json -Encoding utf8
}

function Write-CursorHooksJson([string]$Path, $ExistingHooks, $Pre, $BeforeRead, $BeforeShell) {
    $dir = Split-Path -Parent $Path
    if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $extra = New-Object System.Collections.Generic.List[string]
    if ($ExistingHooks) {
        foreach ($prop in $ExistingHooks.PSObject.Properties) {
            if ($prop.Name -in @("preToolUse", "beforeReadFile", "beforeShellExecution")) { continue }
            $extra.Add(('    "' + $prop.Name + '": ' + ($prop.Value | ConvertTo-Json -Depth 8 -Compress)))
        }
    }
    $extraJson = ""
    if ($extra.Count -gt 0) { $extraJson = ",`n" + ($extra -join ",`n") + "`n" }
    else { $extraJson = "`n" }
    $json = @"
{
  "version": 1,
  "hooks": {
    "preToolUse": $(ConvertTo-JsonArray @($Pre)),
    "beforeReadFile": $(ConvertTo-JsonArray @($BeforeRead)),
    "beforeShellExecution": $(ConvertTo-JsonArray @($BeforeShell))$extraJson  }
}
"@
    Set-Content -LiteralPath $Path -Value $json -Encoding utf8
}

function Test-KplCommand($Value) {
    return ("$Value" -match "kpl-check-read")
}

function Remove-KplEntries($List) {
    $kept = New-Object System.Collections.Generic.List[object]
    foreach ($item in @($List)) {
        if ($null -eq $item) { continue }
        $cmd = $null
        if ($item.PSObject.Properties["command"]) { $cmd = $item.command }
        $nested = @()
        if ($item.PSObject.Properties["hooks"] -and $item.hooks) { $nested = @($item.hooks) }
        $nestedHit = $false
        foreach ($h in $nested) {
            if (Test-KplCommand $h.command) { $nestedHit = $true }
        }
        if ((Test-KplCommand $cmd) -or $nestedHit) { continue }
        $kept.Add($item)
    }
    # Unary comma: PowerShell unwraps single-element collections on return.
    return ,$kept
}

# --- Cursor ---
$cursorPath = Join-Path $Target ".cursor\hooks.json"
$skipCursor = $false
try {
    $cursor = Read-JsonFile $cursorPath
} catch {
    Write-Warning "Skip Cursor hooks.json (invalid JSON): $cursorPath"
    $cursor = $null
    $skipCursor = $true
}
if (-not $skipCursor) {
    if (-not $cursor) {
        $cursor = [pscustomobject]@{ version = 1; hooks = [pscustomobject]@{} }
    }
    if (-not $cursor.hooks) {
        $cursor | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $h = $cursor.hooks
    $pre = Remove-KplEntries $h.preToolUse
    $pre.Add([pscustomobject]@{ command = $HookCmd; matcher = "Read" })
    $beforeRead = Remove-KplEntries $h.beforeReadFile
    $beforeRead.Add([pscustomobject]@{ command = $HookCmd })
    $beforeShell = Remove-KplEntries $h.beforeShellExecution
    $beforeShell.Add([pscustomobject]@{ command = $HookCmd })

    Write-CursorHooksJson $cursorPath $h @($pre.ToArray()) @($beforeRead.ToArray()) @($beforeShell.ToArray())
}

$fragCursor = Join-Path $Target ".cursor\kpl-hooks.json"
if (Test-Path $fragCursor) { Remove-Item -LiteralPath $fragCursor -Force }

# --- Claude ---
$claudePath = Join-Path $Target ".claude\settings.json"
$skipClaude = $false
try {
    $claude = Read-JsonFile $claudePath
} catch {
    Write-Warning "Skip Claude settings.json (invalid JSON): $claudePath"
    $skipClaude = $true
}
if (-not $skipClaude) {
    if (-not $claude) {
        $claude = [pscustomobject]@{ hooks = [pscustomobject]@{} }
    }
    if (-not $claude.hooks) {
        $claude | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $preUse = Remove-KplEntries $claude.hooks.PreToolUse
    $preUse.Add([pscustomobject]@{
        matcher = "Read"
        hooks   = @([pscustomobject]@{ type = "command"; command = $HookCmd })
    })
    $preUse.Add([pscustomobject]@{
        matcher = "Bash"
        hooks   = @([pscustomobject]@{ type = "command"; command = $HookCmd })
    })
    $claude.hooks | Add-Member -NotePropertyName PreToolUse -NotePropertyValue @($preUse.ToArray()) -Force
    Write-JsonFile $claudePath $claude
}

$fragClaude = Join-Path $Target ".claude\kpl-hooks.json"
if (Test-Path $fragClaude) { Remove-Item -LiteralPath $fragClaude -Force }

Write-Host "Merged KPL token-I/O hooks into $Target"
Write-Host "  hook command: $HookCmd"
