# KPL token-I/O gate. Fail-open: any unexpected error allows the tool call.
$ErrorActionPreference = "Stop"

function Write-Allow {
    Write-Output '{"permission":"allow"}'
    exit 0
}

function Write-Deny([string]$Message) {
    $payload = [ordered]@{
        permission    = "deny"
        decision      = "block"
        reason        = $Message
        agent_message = $Message
        user_message  = $Message
    } | ConvertTo-Json -Compress
    Write-Output $payload
    exit 2
}

function Find-RepoRoot {
    $candidates = @()
    if ($PWD -and $PWD.Path) { $candidates += $PWD.Path }
    if ($PSScriptRoot) {
        $candidates += (Split-Path -Parent $PSScriptRoot)           # agents/
        $candidates += (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) # repo
    }
    foreach ($start in $candidates) {
        $cur = $start
        for ($i = 0; $i -lt 8 -and $cur; $i++) {
            if (Test-Path (Join-Path $cur "agents\io-policy.json")) { return $cur }
            if (Test-Path (Join-Path $cur "AGENTS.md")) { return $cur }
            $parent = Split-Path -Parent $cur
            if ($parent -eq $cur) { break }
            $cur = $parent
        }
    }
    return $null
}

function Get-Policy([string]$Root) {
    $defaults = [pscustomobject]@{
        minLines    = 500
        bashWide    = @("cat", "head", "tail", "less", "more")
        narrowPipe  = @("grep", "rg", "findstr", "awk", "sed")
        denyMessage = "File exceeds the KPL read threshold (default 500 lines). Load skill bulk-read. Use Grep or Read with offset/limit."
    }
    if (-not $Root) { return $defaults }
    $path = Join-Path $Root "agents\io-policy.json"
    if (-not (Test-Path $path)) { return $defaults }
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $json = $raw | ConvertFrom-Json
    if (-not $json.minLines) { $json | Add-Member -NotePropertyName minLines -NotePropertyValue 500 }
    if (-not $json.denyMessage) { $json | Add-Member -NotePropertyName denyMessage -NotePropertyValue $defaults.denyMessage }
    return $json
}

function Get-JsonProp($Obj, [string[]]$Names) {
    if (-not $Obj) { return $null }
    foreach ($n in $Names) {
        $p = $Obj.PSObject.Properties[$n]
        if ($p -and $null -ne $p.Value -and "$($p.Value)" -ne "") { return $p.Value }
    }
    return $null
}

function ConvertTo-Int($Value) {
    if ($null -eq $Value -or "$Value" -eq "") { return $null }
    $n = 0
    if ([int]::TryParse("$Value", [ref]$n)) { return $n }
    return $null
}

function Get-LineCount([string]$Path) {
    if (-not $Path -or -not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return @(Get-Content -LiteralPath $Path -ErrorAction Stop).Count
}

function Resolve-ExistingFile([string]$Root, [string]$Rel) {
    if (-not $Rel) { return $null }
    $rel = $Rel.Trim().Trim('"').Trim("'")
    if ([System.IO.Path]::IsPathRooted($rel) -and (Test-Path -LiteralPath $rel -PathType Leaf)) { return $rel }
    if ($Root) {
        $joined = Join-Path $Root $rel
        if (Test-Path -LiteralPath $joined -PathType Leaf) { return $joined }
    }
    if (Test-Path -LiteralPath $rel -PathType Leaf) { return (Resolve-Path -LiteralPath $rel).Path }
    return $null
}

function Test-NarrowPipe([string]$Command, $Policy) {
    $needles = @($Policy.narrowPipe)
    if (-not $needles) { $needles = @("grep", "rg", "findstr", "awk", "sed") }
    foreach ($n in $needles) {
        if ($Command -match "(?i)\|\s*$([regex]::Escape($n))\b") { return $true }
    }
    return $false
}

function Get-BashWideFiles([string]$Command, $Policy) {
    $wide = @($Policy.bashWide)
    if (-not $wide) { $wide = @("cat", "head", "tail", "less", "more") }
    $alt = ($wide | ForEach-Object { [regex]::Escape($_) }) -join "|"
    if ($Command -notmatch "(?i)(^|[;&\n]|&&|\|)\s*($alt)\b") { return @() }
    $tokens = [regex]::Matches($Command, '(?:"[^"]*"|''[^'']*''|[^\s;|&]+)') | ForEach-Object { $_.Value }
    $files = New-Object System.Collections.Generic.List[string]
    foreach ($tok in $tokens) {
        if ($tok -match "^(?i)($alt)$") { continue }
        if ($tok -match "^-" ) { continue }
        if ($tok -match '[|&;]') { continue }
        $unquoted = $tok.Trim('"').Trim("'")
        if ($unquoted -match '[/\\.]' -or (Test-Path -LiteralPath $unquoted)) {
            $files.Add($unquoted)
        }
    }
    return $files
}

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { Write-Allow }

    if ($env:KPL_READ_MIN_LINES -eq "0") { Write-Allow }

    $root = Find-RepoRoot
    $policy = Get-Policy $root
    $min = 500
    if ($env:KPL_READ_MIN_LINES) {
        $parsed = 0
        if ([int]::TryParse($env:KPL_READ_MIN_LINES, [ref]$parsed)) { $min = $parsed }
    }
    elseif ($policy.minLines) { $min = [int]$policy.minLines }
    if ($min -le 0) { Write-Allow }

    $data = $raw | ConvertFrom-Json
    $toolInput = Get-JsonProp $data @("tool_input", "toolInput", "input", "arguments", "args")
    $toolName = Get-JsonProp $data @("tool_name", "toolName", "tool")
    if (-not $toolName -and $toolInput) { $toolName = "Read" }

    $offset = Get-JsonProp $toolInput @("offset", "Offset")
    $limit = Get-JsonProp $toolInput @("limit", "Limit")
    if ($null -eq $offset) { $offset = Get-JsonProp $data @("offset", "Offset") }
    if ($null -eq $limit) { $limit = Get-JsonProp $data @("limit", "Limit") }
    if ($null -ne (ConvertTo-Int $offset) -or $null -ne (ConvertTo-Int $limit)) { Write-Allow }

    $file = Get-JsonProp $toolInput @("file_path", "filePath", "path", "file")
    if (-not $file) { $file = Get-JsonProp $data @("file_path", "filePath", "path", "file") }

    $command = Get-JsonProp $data @("command")
    if (-not $command) { $command = Get-JsonProp $toolInput @("command") }

    $isRead = -not $toolName -or $toolName -match "(?i)^(Read|TabRead|read)$"
    $isShell = $toolName -match "(?i)^(Bash|Shell|bash|shell)$" -or $command

    if ($isRead -and $file) {
        $resolved = Resolve-ExistingFile $root "$file"
        if (-not $resolved) { Write-Allow }
        $lines = Get-LineCount $resolved
        if ($null -eq $lines) { Write-Allow }
        if ($lines -ge $min) { Write-Deny $policy.denyMessage }
        Write-Allow
    }

    if ($isShell -and $command) {
        if (Test-NarrowPipe $command $policy) { Write-Allow }
        $paths = Get-BashWideFiles $command $policy
        foreach ($p in $paths) {
            $resolved = Resolve-ExistingFile $root $p
            if (-not $resolved) { continue }
            $lines = Get-LineCount $resolved
            if ($null -ne $lines -and $lines -ge $min) { Write-Deny $policy.denyMessage }
        }
    }

    Write-Allow
}
catch {
    Write-Allow
}
