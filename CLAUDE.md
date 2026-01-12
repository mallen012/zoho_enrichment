# CLAUDE.md - Perdigon Group

## Project Overview
Perdigon Group is an MSP and Cisco Webex/Meraki partner. This codebase contains automation workflows, integrations, and tools for sales operations, customer deployments, and service delivery.

Claude should tailor all responses toward helping me design, build, automate, and scale applications and workflows for Perdigon, a Cisco Webex and IT services partner. My work focuses on:

Automating sales operations, prospecting, customer deployments, and service delivery.

Integrating and streamlining business systems, including Zoho CRM Plus, Quoter, QuickBooks, and other platforms used for quoting, accounting, and pipeline management.

Building new tools and applications from scratch when existing platforms are insufficient.

Developing APIs, microservices, and automation workflows across Webex, Zoho, Home Assistant, n8n, Docker-based services, and internal applications.

Claude should provide answers that are:

1. Direct, technical, and actionable

Offer clear solutions, code examples, architectural diagrams, and implementation-ready steps.

Avoid vague advice; show working patterns, best practices, and recommended tools.

2. Optimized for building real systems

Prioritize scalable, maintainable, production-friendly approaches.

Be opinionated when needed—tell me the best way, not every way.

3. Focused on business impact

Whenever possible, tie technical solutions to operational efficiency, customer experience, and improved workflows for Perdigon’s business model.

4. Integrative

Show how systems connect: CRM → quoting → accounting → provisioning → notifications → customer follow-up.

Provide help with API integrations, data models, workflow logic, and automation across platforms.

5. Fast, practical problem-solving

Help debug issues, improve code quality, design workflows, and automate repetitive processes.

Provide cheatsheets, templates, boilerplate code, and sample payloads on request.

6. Proactive

Suggest better alternatives or optimizations I may not have considered.

Offer ways to simplify processes, reduce manual steps, and automate business operations further.

Suggest Multiple choice answers when you have questions to keep interactions fast and concise

## Business Context
- **Primary Services:** Cisco Webex Calling, Meetings, Meraki networking
- **CRM:** Zoho CRM Plus (CRM, Desk, Campaigns, etc.)
- **Automation Platform:** n8n on Hostinger VPS (https://n8n.srv1127126.hstgr.cloud)
- **Payment Processing:** Stripe
- **Customer Count:** ~30 service customers, scaling to 500 over 2 years

## Architecture

### Core Systems
```
Zoho CRM → n8n Webhooks → Business Logic → Outputs
                ↓
         [Webex APIs, Stripe, Google Calendar, MerakiMCP]
```

### Key Integrations
| System | Purpose | Auth Method |
|--------|---------|-------------|
| Zoho CRM | Customer records, deals, tasks | OAuth2 |
| Zoho Desk | Support tickets (being replaced) | OAuth2 |
| Stripe | Invoicing, subscriptions | API Key |
| Webex | Bot messaging, rooms, calling | Bot Token |
| Google Calendar | Scheduling consultations | OAuth2 |
| Meraki Dashboard | Network audits, configs | API Key per customer |

## Active Projects

### 1. Meraki Network Audit System
**Status:** In development
**Location:** `n8n-workflows/meraki-audit/`

**Flow:**
1. Zoho CRM button (Accounts/Deals module) → Pre-flight form
2. Form collects: audit scope, scheduling preference
3. n8n workflow executes MerakiMCP tools
4. Generates: DOCX report, findings analysis
5. Creates: Zoho tasks, Stripe invoice ($200), Calendar event
6. Notifications: Webex room with stakeholders

**Audit Scopes:**
- Network Audit (full)
- Security Audit
- Quick Check
- Cloud Voice & Meetings Prep (Webex Calling readiness)

**Key Files:**
- `meraki-audit-preflight-form.html` - Customer-facing form with scheduling
- `meraki-audit-workflow.json` - Main n8n workflow
- `meraki-audit-setup-guide.md` - Configuration documentation

**Zoho Custom Fields Required:**
- `Meraki_API_Key` on Accounts module

### 2. Perdi Bot (Webex Assistant)
**Status:** Working, needs verification
**Workflow:** "Perdi - Full Agent v3.1 (With Memory)"

**Capabilities:**
- Webex message handling via webhook
- RAG search against Qdrant knowledge base
- Session memory (buffer window)
- Confidence scoring + escalation logic
- Stripe customer lookup

### 3. Service Desk Platform
**Status:** Planning phase
**Goal:** Replace Zoho Desk with custom solution

**Planned Features:**
- Ticketing system with AI triage
- Customer portal
- Knowledge base with RAG
- Separate deployments for Perdigon and WYFY.ai

## n8n Workflow Conventions

### Naming
- Prefix production workflows: `PROD - `
- Prefix test workflows: `TEST - `
- Include version: `v1.0`, `v1.1`, etc.

### Webhook Security
- All webhooks require `key` parameter validation
- Secret key stored in n8n environment variables
- Pattern: `?key=YourSecretKey2026`

### Error Handling
- All workflows should have error branch
- Errors post to dedicated Webex room
- Return meaningful error responses to callers

## Zoho CRM Patterns

### Button URLs (Accounts Module)
```
https://[FORM_URL]?account_id=${Accounts.Account Id}&account_name=${Accounts.Account Name}&owner_email=${Accounts.Owner.email}&key=SECRET
```

### Button URLs (Deals Module)
```
https://[FORM_URL]?account_id=${Deals.Account_Name.Account Id}&deal_id=${Deals.Deal Id}&key=SECRET
```

### Task Creation
- Subject format: `[Type]: [Customer] - [Description]`
- Example: `Meraki Audit: Acme Corp - Fixes and Recommendations`
- Always attach relevant documents
- Set Owner based on webhook `owner_id`

## Environment Variables (n8n)
```
WORKFLOW_SECRET_KEY=<secret>
MIKE_ALLEN_EMAIL=mike.allen@perdigon-group.com
PERDI_BOT_EMAIL=perdi@webex.bot
WEBEX_BOT_TOKEN_PERDI=NzE0MmY0MTctMDA2MC00NTQ5LTkyNTMtOGYwOGZkMmVmMjg5NjFmMGM0OTYtMGNl_P0A1_111961d0-fa6b-4fe7-b146-96d757593b2d
STRIPE_SECRET_KEY=<key>
```

## API Endpoints

### n8n Webhooks (Hostinger)
- Base: `https://n8n.srv1127126.hstgr.cloud/webhook/`
- Form serving: `GET /webhook/meraki-audit-form`
- Form submission: `POST /webhook/meraki-audit`
- Availability check: `GET /webhook/meraki-audit-availability`

## Development Guidelines

### DO:
- Export workflow JSON after significant changes
- Test with sandbox/test accounts first
- Document webhook parameters in workflow notes
- Use Code nodes for complex logic (easier to debug)

### DON'T:
- Hardcode customer API keys in workflows
- Skip error handling branches
- Modify production workflows without testing
- Assume Zoho field names—verify API names

## File Structure
```
perdigon/
├── CLAUDE.md                    # This file
├── n8n-workflows/
│   ├── meraki-audit/
│   │   ├── meraki-audit-workflow.json
│   │   └── meraki-audit-form.html
│   ├── perdi-bot/
│   │   └── perdi-agent-v3.1.json
│   └── zoho-webhooks/
│       └── crm-button-handlers.json
├── zoho-integrations/
│   ├── button-configs.md
│   └── custom-fields.md
└── docs/
    ├── meraki-audit-setup-guide.md
    └── service-desk-requirements.md
```

## Known Issues / TODOs
- [ ] Verify Perdi bot email handling is working
- [ ] Verify Perdi scheduling page functionality
- [ ] Complete Meraki audit pre-flight form deployment
- [ ] Test Stripe invoice creation flow
- [ ] Set up MCP servers in Claude Code

## Related Resources
- WYFY.ai project: `~/projects/wyfy/`
- Shared MCP servers: `~/projects/shared/mcp-servers/`
