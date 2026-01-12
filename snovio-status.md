# Snovio Contact Finder - Status & Pending Fixes

**Last Updated:** 2026-01-11
**Workflow ID:** `pvdUlL8oUiLlSvkD`
**Workflow Name:** Snovio Contact Finder (Zoho Accounts)
**Status:** Active, partially working

## What's Working
- Zoho button on Accounts page triggers popup
- Snovio v2 API async flow (Start Search → Wait 3s → Get Results)
- Popup displays prospects with Perdigon branding
- Contact import creates Zoho contacts
- Email lookup flow exists (Start Email Lookup → Wait 2s → Get Email Result)

## What's NOT Working

### 1. Account Auto-Update (CRITICAL)
**Node:** `Parse Snovio Results`
**Problem:** `accountUpdates` object is always empty `{}`
**Fix:** Add logic to populate company data from Snovio response:
```javascript
const accountUpdates = {};
const company = snovio.meta || {};

if (!accountData.currentPhone && company.hq_phone) {
  accountUpdates.Phone = company.hq_phone;
}
if (!accountData.currentIndustry && company.industry) {
  accountUpdates.Industry = company.industry;
}
if (!accountData.currentCity && company.city) {
  accountUpdates.Billing_City = company.city;
}
// Add more fields: Billing_Street, Billing_State, Billing_Code, Billing_Country
// Also save company logo URL if available: company.logo
```

### 2. Unverified Tag Logic (CRITICAL)
**Node:** `Contact Created?`
**Problem:** Condition checks `$json.data?.[0]?.code === 'SUCCESS'` - adds tag on ALL successful creates
**Should:** Check `$json.isVerified === false` - only add tag when email is unverified
**Current Flow:**
- SUCCESS → Add Unverified Tag (WRONG)
- FAIL → Log Contact Result

**Correct Flow:**
- `!isVerified` → Add Unverified Tag
- `isVerified` → Log Contact Result (skip tag)

### 3. Missing Snovio Credits Display
**Problem:** No credits balance shown on popup
**Fix:** Add HTTP node before Build Popup HTML:
- `GET https://api.snov.io/v1/get-balance`
- Pass `access_token` from Snovio: Get Token
- Display in popup header: "Credits: X / Y"

### 4. Email Not Importing
**Problem:** Email lookup may not be returning data correctly
**Node:** `Parse Email Result`
**Debug:** Check if v2 API response structure matches parser expectations

## Pending Enhancements (from user requests)

| Priority | Feature | Description |
|----------|---------|-------------|
| HIGH | Click-to-lookup emails | Click contact name to fetch email, row turns green/orange |
| HIGH | Credits display | Show Snovio balance on popup |
| MEDIUM | Position filters | Dropdown with smart groupings (Executive, Director, Manager) |
| MEDIUM | Search bar | Filter by name/position text |
| MEDIUM | Pagination | Next/Prev for 20+ results |
| LOW | Email domain field | Extract domain, save to Account field |

## Snovio API Credentials
- User ID: `d37f94b18ce02ece5f401ce8683b258e`
- Secret: `45b473e4d2f48e928c9bafd7fcbcd853`
- Account: Pro (5k/month, 60k credits available)

## Zoho Field Mappings (Planned)

### Contacts
| Snovio Field | Zoho Contact Field |
|--------------|-------------------|
| first_name | First_Name |
| last_name | Last_Name |
| email | Email |
| position | Title |
| source_page | LinkedIn_Contact_Profile_URL |
| (static) | Lead_Source = "Snovio" |
| (static) | Enriched_Source = "Snovio" |
| id/hash | Snov_io_ID (needs to be added) |

### Accounts (auto-update if empty)
| Snovio Field | Zoho Account Field |
|--------------|-------------------|
| company_name | Account_Name |
| hq_phone | Phone |
| industry | Industry |
| city | Billing_City |
| logo | (custom field or Record_Image) |

## Endpoints
- **Search:** `GET https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=XXX`
- **Save:** `POST https://n8n.srv1127126.hstgr.cloud/webhook/snovio-save`

## MCP Servers Configured
- `n8n-perdigon` - Your n8n instance (read/execute only)
- `n8n-mcp` - n8n-mcp.com (needs auth setup for write)
- `mcp-zohosnovio` - Zoho Snovio integration
- `perdicrm` - Zoho CRM
- `perdidesk` - Zoho Desk

## Next Steps
1. Restart Claude Code to activate MCP tools
2. Tell Claude: "Read snovio-status.md and continue fixing the Snovio workflow"
3. If n8n write tools available, apply fixes directly
4. If not, apply fixes manually in n8n UI
