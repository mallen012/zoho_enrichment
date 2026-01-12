$json = Get-Content 'C:\Users\mikea\.claude\projects\C--Users-mikea-projects-perdigon-perdigon-zoho-integrations\8aae6df5-ece7-49a5-9821-344434e262a3\tool-results\mcp-n8n-mcp-n8n_get_workflow-1768194504146.txt' -Raw | ConvertFrom-Json
$workflow = $json[0].text | ConvertFrom-Json
$workflow.nodes | ForEach-Object { $_.name }
