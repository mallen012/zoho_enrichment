$raw = Get-Content 'C:\Users\mikea\.claude\projects\C--Users-mikea-projects-perdigon-perdigon-zoho-integrations\8aae6df5-ece7-49a5-9821-344434e262a3\tool-results\mcp-n8n-mcp-n8n_get_workflow-1768194504146.txt' -Raw
Write-Host "Raw length: $($raw.Length)"
$json = $raw | ConvertFrom-Json
Write-Host "JSON type: $($json.GetType().Name)"
Write-Host "JSON count: $($json.Count)"
if ($json.Count -gt 0) {
    $first = $json[0]
    Write-Host "First item type: $($first.type)"
    $text = $first.text
    Write-Host "Text length: $($text.Length)"
    Write-Host "Text start: $($text.Substring(0, [Math]::Min(500, $text.Length)))"
}
