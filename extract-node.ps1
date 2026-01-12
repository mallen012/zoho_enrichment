$content = Get-Content -Path 'C:\Users\mikea\.claude\projects\C--Users-mikea-projects-perdigon-perdigon-zoho-integrations\8aae6df5-ece7-49a5-9821-344434e262a3\tool-results\mcp-n8n-mcp-n8n_get_workflow-1768176498665.txt' -Raw

Write-Output "=== Raw content first 500 chars ==="
Write-Output $content.Substring(0, 500)
Write-Output "..."

$data = $content | ConvertFrom-Json
Write-Output ""
Write-Output "=== Data type ==="
Write-Output $data.GetType().FullName
Write-Output "=== Data count ==="
Write-Output $data.Count
Write-Output "=== First item type ==="
Write-Output $data[0].GetType().FullName
Write-Output "=== First item keys ==="
Write-Output ($data[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
