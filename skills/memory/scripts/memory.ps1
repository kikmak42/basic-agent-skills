<#
.SYNOPSIS
    Persistent key-value memory store for agents.

.DESCRIPTION
    Stores, retrieves, lists, searches, and deletes named memories in a local
    JSON file (~/.agent-memory.json by default). Memories survive across
    agent sessions, conversations, and reboots.

.PARAMETER Operation
    set | get | list | delete | search | clear | export | import | tag | note

.PARAMETER Key
    Memory key (dot-notation recommended: "project.api_url")

.PARAMETER Value
    Value to store (for 'set')

.PARAMETER Query
    Search term for 'search' operation

.PARAMETER Tags
    Comma-separated tags: "api,config,project"

.PARAMETER Note
    Human-readable description of what this memory is for

.PARAMETER File
    Path to JSON file for 'import' operation

.PARAMETER StorePath
    Override the default store path (~/.agent-memory.json)

.PARAMETER Confirm
    Required for the 'clear' operation to prevent accidental data loss

.EXAMPLE
    .\memory.ps1 -Operation set -Key "api.base_url" -Value "https://api.example.com" -Tags "api,config" -Note "Production API"
    .\memory.ps1 -Operation get -Key "api.base_url"
    .\memory.ps1 -Operation list
    .\memory.ps1 -Operation search -Query "api"
    .\memory.ps1 -Operation delete -Key "api.base_url"
    .\memory.ps1 -Operation clear -Confirm
    .\memory.ps1 -Operation export
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("set","get","list","delete","search","clear","export","import","tag","note")]
    [string] $Operation,

    [string] $Key       = "",
    [string] $Value     = "",
    [string] $Query     = "",
    [string] $Tags      = "",
    [string] $Note      = "",
    [string] $File      = "",
    [string] $StorePath = "",
    [switch] $Confirm
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Resolve store path ───────────────────────────────────────────────────────
if ($StorePath -eq "") {
    $StorePath = if ($env:AGENT_MEMORY_PATH) { $env:AGENT_MEMORY_PATH }
                 else { Join-Path $HOME ".agent-memory.json" }
}

# ─── Load store ───────────────────────────────────────────────────────────────
function Load-Store {
    if (-not (Test-Path $StorePath)) {
        return @{ version = "1.0"; memories = @{} }
    }
    $raw = Get-Content $StorePath -Raw -Encoding UTF8
    $obj = $raw | ConvertFrom-Json
    # Convert memories from PSCustomObject to hashtable for easy mutation
    $ht = @{}
    foreach ($prop in $obj.memories.PSObject.Properties) {
        $m = $prop.Value
        $ht[$prop.Name] = @{
            value   = $m.value
            tags    = @($m.tags)
            note    = if ($m.note) { $m.note } else { "" }
            created = $m.created
            updated = $m.updated
        }
    }
    return @{ version = $obj.version; memories = $ht }
}

# ─── Save store ───────────────────────────────────────────────────────────────
function Save-Store($store) {
    $store | ConvertTo-Json -Depth 10 | Set-Content $StorePath -Encoding UTF8
}

# ─── Timestamp helper ─────────────────────────────────────────────────────────
function Now-Ts { (Get-Date).ToString("o") }

# ─── Separator line ───────────────────────────────────────────────────────────
function Sep { "─" * 54 }

# ─── Tag parsing ──────────────────────────────────────────────────────────────
function Parse-Tags($tagStr) {
    if ($tagStr -eq "") { return @() }
    return @($tagStr -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
}

# ═════════════════════════════════════════════════════════════════════════════
#  Operations
# ═════════════════════════════════════════════════════════════════════════════

$store = Load-Store

switch ($Operation) {

    # ── SET ──────────────────────────────────────────────────────────────────
    "set" {
        if ($Key -eq "") { Write-Error "❌ -Key is required for 'set'"; exit 1 }
        if ($Value -eq "") { Write-Error "❌ -Value is required for 'set'"; exit 1 }

        $isUpdate = $store.memories.ContainsKey($Key)
        $created  = if ($isUpdate) { $store.memories[$Key].created } else { Now-Ts }

        # Use imperative style + [array] cast to avoid PowerShell empty-array null-collapse
        [array]$parsedTags = @()
        if     ($Tags -ne "") { $parsedTags = @(Parse-Tags $Tags) }
        elseif ($isUpdate)    { $parsedTags = @($store.memories[$Key].tags) }

        $parsedNote = ""
        if     ($Note -ne "") { $parsedNote = $Note }
        elseif ($isUpdate)    { $parsedNote = $store.memories[$Key].note }

        $store.memories[$Key] = @{
            value   = $Value
            tags    = $parsedTags
            note    = $parsedNote
            created = $created
            updated = Now-Ts
        }
        Save-Store $store

        $action = if ($isUpdate) { "Updated" } else { "Saved" }
        Write-Output "✅ ${action}: $Key"
        Write-Output "   Value : $Value"
        if ($parsedTags.Count -gt 0) { Write-Output "   Tags  : $($parsedTags -join ', ')" }
        if ($parsedNote -ne "")      { Write-Output "   Note  : $parsedNote" }
        Write-Output "   Saved : $(Now-Ts)"
    }

    # ── GET ──────────────────────────────────────────────────────────────────
    "get" {
        if ($Key -eq "") { Write-Error "❌ -Key is required for 'get'"; exit 1 }
        if (-not $store.memories.ContainsKey($Key)) {
            Write-Output "❌ Key not found: $Key"
            Write-Output "   Run -Operation list to see all stored keys."
            exit 1
        }
        $m = $store.memories[$Key]
        Write-Output "Key    : $Key"
        Write-Output "Value  : $($m.value)"
        if ($m.tags.Count -gt 0) { Write-Output "Tags   : $($m.tags -join ', ')" }
        if ($m.note -ne "")      { Write-Output "Note   : $($m.note)" }
        Write-Output "Created: $($m.created)"
        Write-Output "Updated: $($m.updated)"
    }

    # ── LIST ─────────────────────────────────────────────────────────────────
    "list" {
        $filterTag = if ($Tags -ne "") { ($Tags -split ",")[0].Trim() } else { "" }
        $entries = $store.memories.GetEnumerator() | Sort-Object Key
        if ($filterTag -ne "") {
            $entries = $entries | Where-Object { $_.Value.tags -contains $filterTag }
        }
        $arr = @($entries)
        $tagLabel = if ($filterTag -ne "") { " [tag: $filterTag]" } else { "" }
        Write-Output "📦 Memory store — $($arr.Count) entr$(if($arr.Count -eq 1){'y'}else{'ies'})$tagLabel  ($StorePath)"
        Write-Output (Sep)
        if ($arr.Count -eq 0) {
            Write-Output "  (empty)"
        } else {
            foreach ($e in $arr) {
                $tagStr = if ($e.Value.tags.Count -gt 0) { "  [$($e.Value.tags -join ', ')]" } else { "" }
                $noteStr = if ($e.Value.note -ne "") { "  — $($e.Value.note)" } else { "" }
                "  {0,-28}{1}{2}" -f $e.Key, $tagStr, $noteStr
            }
        }
    }

    # ── DELETE ───────────────────────────────────────────────────────────────
    "delete" {
        if ($Key -eq "") { Write-Error "❌ -Key is required for 'delete'"; exit 1 }
        if (-not $store.memories.ContainsKey($Key)) {
            Write-Output "❌ Key not found: $Key"
            exit 1
        }
        $store.memories.Remove($Key)
        Save-Store $store
        Write-Output "🗑️  Deleted: $Key"
    }

    # ── SEARCH ───────────────────────────────────────────────────────────────
    "search" {
        if ($Query -eq "") { Write-Error "❌ -Query is required for 'search'"; exit 1 }
        $q = $Query.ToLower()
        # Use foreach instead of nested Where-Object to avoid StrictMode issues
        $found = [System.Collections.Generic.List[object]]::new()
        foreach ($kv in ($store.memories.GetEnumerator() | Sort-Object Key)) {
            $kLow  = $kv.Key.ToLower()
            $vLow  = $kv.Value.value.ToLower()
            $nLow  = if ($kv.Value.note) { $kv.Value.note.ToLower() } else { "" }
            $tagHit = $false
            foreach ($tag in @($kv.Value.tags)) {
                if ($tag -and $tag.ToLower() -like "*$q*") { $tagHit = $true; break }
            }
            if ($kLow -like "*$q*" -or $vLow -like "*$q*" -or $nLow -like "*$q*" -or $tagHit) {
                $found.Add($kv)
            }
        }
        $arr = @($found)
        Write-Output "🔍 Search results for `"$Query`" — $($arr.Count) match$(if($arr.Count -eq 1){''}else{'es'})"
        Write-Output (Sep)
        if ($arr.Count -eq 0) {
            Write-Output "  No matches found."
        } else {
            foreach ($e in $arr) {
                "  {0,-28} {1}" -f $e.Key, $e.Value.value
            }
        }
    }

    # ── CLEAR ────────────────────────────────────────────────────────────────
    "clear" {
        if (-not $Confirm) {
            Write-Output "⚠️  WARNING: This will permanently delete ALL memories in $StorePath"
            Write-Output "   Re-run with -Confirm to proceed:"
            Write-Output "   .\memory.ps1 -Operation clear -Confirm"
            exit 0
        }
        $count = $store.memories.Count
        $store.memories = @{}
        Save-Store $store
        Write-Output "🧹 Cleared $count memor$(if($count -eq 1){'y'}else{'ies'}) from $StorePath"
    }

    # ── EXPORT ───────────────────────────────────────────────────────────────
    "export" {
        if (-not (Test-Path $StorePath)) {
            Write-Output "# Store is empty — nothing to export."
            exit 0
        }
        Get-Content $StorePath -Raw -Encoding UTF8
    }

    # ── IMPORT ───────────────────────────────────────────────────────────────
    "import" {
        if ($File -eq "") { Write-Error "❌ -File is required for 'import'"; exit 1 }
        if (-not (Test-Path $File)) { Write-Error "❌ File not found: $File"; exit 1 }
        $raw     = Get-Content $File -Raw -Encoding UTF8
        $import  = $raw | ConvertFrom-Json
        $added   = 0; $updated = 0
        foreach ($prop in $import.memories.PSObject.Properties) {
            $k = $prop.Name; $v = $prop.Value
            $isUpdate = $store.memories.ContainsKey($k)
            $store.memories[$k] = @{
                value   = $v.value
                tags    = @($v.tags)
                note    = if ($v.note) { $v.note } else { "" }
                created = if ($isUpdate) { $store.memories[$k].created } else { if ($v.created) { $v.created } else { Now-Ts } }
                updated = Now-Ts
            }
            if ($isUpdate) { $updated++ } else { $added++ }
        }
        Save-Store $store
        Write-Output "📥 Import complete: $added added, $updated updated"
    }

    # ── TAG ──────────────────────────────────────────────────────────────────
    "tag" {
        if ($Key -eq "")  { Write-Error "❌ -Key is required for 'tag'"; exit 1 }
        if ($Tags -eq "") { Write-Error "❌ -Tags is required for 'tag'"; exit 1 }
        if (-not $store.memories.ContainsKey($Key)) { Write-Error "❌ Key not found: $Key"; exit 1 }
        $store.memories[$Key].tags    = Parse-Tags $Tags
        $store.memories[$Key].updated = Now-Ts
        Save-Store $store
        Write-Output "🏷️  Tags updated for '$Key': $($store.memories[$Key].tags -join ', ')"
    }

    # ── NOTE ─────────────────────────────────────────────────────────────────
    "note" {
        if ($Key -eq "")  { Write-Error "❌ -Key is required for 'note'"; exit 1 }
        if ($Note -eq "") { Write-Error "❌ -Note is required for 'note'"; exit 1 }
        if (-not $store.memories.ContainsKey($Key)) { Write-Error "❌ Key not found: $Key"; exit 1 }
        $store.memories[$Key].note    = $Note
        $store.memories[$Key].updated = Now-Ts
        Save-Store $store
        Write-Output "📝 Note updated for '$Key'"
    }
}
