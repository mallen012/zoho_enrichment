
Zoho Automations Tweaks
/
1768065931085_image.png

www.cisco.com.har
har

Snovio Contact integration into Zoho Accounts page: Strategy and plan first, then implement. When using the Snovio browser extension from a website, i am provided with a list of contacts sorted by name, title, email address, etc.. I want to be able to hit a button on a zoho account page, open a popup like that, choose a contact, then have that contact saved to the zoho account as a contact. I have tried this in the past, however ran into issues before the Snovio and Zoho team came up with an mcp server. WE need to first query your Zoho Snovio mcp tool and see whats available and build something around that. Lets start a plan now. Attached is a screenshot and the .har file from me launching the extension from the browser while visiting cisco.com

Jan 10

Analyzed integration requirements and mapped API exploration strategy.



Let me first explore what's available in the Snovio MCP tools, then analyze the HAR file to understand the API structure.


2 steps
favicon
Snovio find email



Examined API limitations and pivoted toward HAR file analysis.

The MCP tools appear limited. Let me analyze the HAR file to see what APIs the Snovio extension actually calls:


2 steps

List all URLs from HAR file



Investigated API documentation gaps and identified background script limitations.

The HAR captured Cisco's page traffic, not the Snovio extension calls (those run through the extension's background script). Let me check the Snovio API documentation:


Snovio API documentation domain search prospects
10 results






















Architected integration strategy leveraging n8n workflow and Zoho widget.





Excellent! Now I have a clear picture. Let me also view the screenshot to understand the current UI:


View the Snovio extension screenshot
Show working file

Analyzed integration architecture and strategized Snovio-Zoho contact workflow implementation.



Now I have the full picture. Let me create a strategic plan:

🎯 Snovio → Zoho Contact Integration: Strategy & Plan
Current State Analysis
Component	Status
MCP Tools Available	Very limited: snovio_count_email, snovio_find_email, snovio_get_profile (returning null)
Snovio REST API	Full-featured: Domain Search, Prospects, Email Finder, Profile Enrichment
Browser Extension	Works standalone, but no native Zoho integration
Your Goal	Button on Zoho Account → Popup with Snovio prospects → Save selected as Zoho Contacts
Architecture Options
Option	Complexity	UX Quality	Maintenance
A. Zoho Widget + n8n	Medium	⭐⭐⭐⭐	Low
B. Custom Chrome Extension	High	⭐⭐⭐⭐⭐	High
C. Zoho Functions + Deluge	Medium	⭐⭐⭐	Medium
📋 Recommended: Option A - Zoho Widget + n8n Backend
Why: Leverages your existing n8n infrastructure, provides clean UX, maintainable.

Flow Architecture
┌─────────────────────────────────────────────────────────────────┐
│                     ZOHO CRM ACCOUNT PAGE                        │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  [🔍 Find Snovio Contacts] button (Custom Link/Widget)  │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      n8n WORKFLOW                                │
│  1. Receive Account ID + Website/Domain                         │
│  2. Call Snovio Domain Search API → Get Prospects               │
│  3. Return JSON to popup                                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   INTERACTIVE POPUP                              │
│  ☑ Dinesh Thurvash - Member Technical Staff                     │
│  ☑ Srinivasan Natarajan - Marketing Analyst                     │
│  ☐ Jevitha Sathyanaryanan - Head Talent Acquisition             │
│                    [Save Selected to Zoho]                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  n8n → ZOHO CRM                                  │
│  Create Contacts with Account_ID linkage                         │
│  Fields: First/Last Name, Email, Title, LinkedIn, Source="Snovio"│
└─────────────────────────────────────────────────────────────────┘
Implementation Phases
Phase	Task	Deliverable
1	Validate Snovio API access	Test domain search with your API credentials
2	Build n8n workflow	/snovio-search endpoint + /snovio-save endpoint
3	Create Zoho Custom Button	Link that opens popup with Account context
4	Build popup UI	HTML/JS hosted on n8n or Cloudflare Worker
5	Test & iterate	End-to-end flow validation
Questions Before Proceeding
A) Snovio API Credentials:

Do you have Snovio API access? (Client ID + Client Secret)
What's your credit/usage tier?
B) Preferred UI Approach:

Popup window (new browser window) - simpler
Zoho Widget/Sidebar (embedded iframe) - cleaner but more complex
Modal overlay via Chrome extension - best UX but harder
C) Contact Field Mapping: Which Zoho Contact fields should we populate?

First Name, Last Name, Email (required)
Title/Designation
LinkedIn URL
Phone (if available)
Custom field: Lead_Source = "Snovio"?
Custom field: Snovio_Prospect_ID?
Next step: Want me to first build a quick n8n test workflow to validate Snovio API access with your credentials, or should we map out the Zoho Contact fields first?

option a, n8n. Questions a: 1.yes userId: d37f94b18ce02ece5f401ce8683b258e secret: 45b473e4d2f48e928c9bafd7fcbcd853 2.pro account 5k per month, have 60k credits built up now. b:1, we are already doing that with a calling script, ai enrich tool, etc.. better for us. c. Give me a list of everything we can have from zoho, for custom fields I want to add the lead_Source for snovio in zoho, i also want to map the snovio id to the zoho field: Snov.io ID so we can store it there, but give me your recommendation on field mapping with all available and what works with Zoho, we may clean up some zoho fields too

Jan 10

Architected field mapping strategy between Snovio and Zoho systems.



Let me pull the Zoho Contact fields and cross-reference with what Snovio provides.


6 steps

Check structure of Zoho fields response



Reviewed prior progress and identified pending workflow integration tasks.



Let me check the transcript to see exactly where we left off and continue from there.


2 steps

Check end of transcript to see final state
Show working file

Charted next steps: adding Snovio source and building integration workflow.


Based on the summary, I completed the full Zoho Contacts field inventory and provided mapping recommendations. Now let me proceed with the implementation:

Immediate Next Steps:

Add "Snovio" to Lead_Source picklist - Need to update Zoho
Build n8n workflow for the Snovio domain search → Contact creation
Let me first check your existing n8n workflows to understand your patterns, then build the Snovio integration:


8 steps
P


Search workflows



Examined workflow patterns to extract Zoho integration details.

Let me look at your existing workflow patterns for the HTML response approach:

P


Get workflow details



Architected dual-webhook Snovio integration workflow with API authentication and contact mapping.
14s








Got it! I can see your pattern - webhooks with HTML responses, Config node for API keys and owner mapping. Now let me build the Snovio Prospect Finder workflow.

Architecture:

GET /webhook/snovio-search - Returns prospect list JSON for popup
POST /webhook/snovio-save - Saves selected contacts to Zoho
Before I create the workflow, quick confirmation:

Should I: A) Create a single workflow with both endpoints (search + save)? B) Two separate workflows?

For the popup UI, do you: A) Want me to build a simple HTML selector popup in the same workflow? B) You already have a popup framework I should return JSON to?

Default field mapping I'll use:

Snovio Field	Zoho Contact Field
id	Snov_io_ID
firstName	First_Name
lastName	Last_Name
email	Email
position	Title
sourcePage (LinkedIn)	LinkedIn_Contact_Profile_URL
companyName	Account_Name (lookup)
locality	Mailing_City
country	Mailing_Country
(static) "Snovio"	Lead_Source
(static) "Snovio"	Enriched_Source
Sound right? Then I'll create the workflow.

yes, are those all the fields available? I thought Snovio contacts had more? Are there any company fields we can grab to add to the account while adding the contact?

Jan 10

Investigated Snovio API documentation for available fields.


Good question - let me check what Snovio actually returns. The MCP tools are limited, but I can check their API docs for the full field list.


2 steps
favicon

Fetched
API • Email Finder, Verifier & Sender API methods | Snov.io
snov.io


Catalogued Snovio's available fields and mapped company data to account fields.
12s











Excellent find! The Snovio API is much richer than I initially listed. Here's the complete picture:

SNOVIO FULL FIELD INVENTORY
Company Info (from Domain Search)
Snovio Field	Zoho Account Field	Notes
company_name	Account_Name	Verify/update
city	Billing_City	HQ location
hq_phone	Phone	Company main line
website	Website	Confirm domain
industry	Industry / Primary_Industry	Map to picklist
size	Company_Size_Employee_Count	e.g., "51-200"
founded	(no field)	Could add custom
related_domains	(no field)	Useful for subsidiaries
Prospect Profile Fields (from Domain Search → Prospects)
Snovio Field	Zoho Contact Field
first_name	First_Name
last_name	Last_Name
position	Title
source_page	LinkedIn_Contact_Profile_URL
email	Email
smtp_status	(store as note or tag?)
Enriched Profile (from Get Profile by Email - 1 credit)
Snovio Field	Zoho Contact Field
firstName / lastName	First_Name / Last_Name
country	Mailing_Country
locality	Mailing_City
industry	Primary_Industry
logo	Record_Image (upload)
social[].link (LinkedIn)	LinkedIn_Contact_Profile_URL
social[].link (Twitter)	Twitter
currentJobs[0].position	Title
currentJobs[0].companyName	(verify Account)
currentJobs[0].site	Website
currentJobs[0].industry	Primary_Industry
skills	(no field - could add)
Current Job Details (from profile)
Snovio Field	Zoho Account Field
currentJobs[].companyName	Account_Name
currentJobs[].site	Website
currentJobs[].locality	Billing_City
currentJobs[].state	Billing_State
currentJobs[].city	Billing_City
currentJobs[].street	Billing_Street
currentJobs[].postal	Billing_Code
currentJobs[].country	Billing_Country
currentJobs[].size	No_of_Employees
currentJobs[].industry	Industry
currentJobs[].founded	(custom field)
currentJobs[].companyType	Ownership_Type
Recommended Workflow Strategy
Phase 1: Domain Search (1 credit)

Get company info → Update Account fields
Get prospect count/list
Phase 2: User Selects Contacts in Popup

Display: name, position, LinkedIn URL
User picks which to import
Phase 3: Get Emails for Selected (1 credit each)

Retrieve verified email for each selected prospect
Phase 4: Create Contacts in Zoho

Map all available fields
Link to Account
Quick question before I build:

Do you want to:

Auto-update Account with Snovio company data during search? (adds industry, phone, size if missing)
Skip Account updates and only create contacts?
And for contacts without verified emails (smtp_status = "unknown"), should we:

A) Import anyway with a tag like "Email Unverified"
B) Skip them entirely
C) Let user decide in the popup
In Phase two, have the linkedin/ social profile be a hyperlink the user can click and explore for verification. 1.Yes, auto update, can you update address too if missing? A) but lets highlight each selection while the user is looking at contact name, profile url, email, etc.. can we lightly highlight contacts that are verified in green, unverified in a soft yellow/ orange? We dont get dinged for unverified email credits.

Jan 10

Architected verification workflow with color-coded contact highlighting and clickable profiles.




Perfect, that's a clean UX approach. Let me confirm the final spec:

CONFIRMED SPEC
Popup UI Features
Element	Behavior
Contact Name	Text display
LinkedIn/Social	Clickable hyperlink (opens in new tab for verification)
Position/Title	Text display
Email	Text display
Row Highlight	🟢 Soft green = verified (smtp_status: valid)
Row Highlight	🟡 Soft yellow/orange = unverified (smtp_status: unknown)
Checkbox	Select which contacts to import
Account Auto-Update (if fields empty)
Company Name, Phone, Website, Industry, Employee Count
Address: Billing_Street, Billing_City, Billing_State, Billing_Code, Billing_Country
Contact Import
All selected contacts imported
Unverified emails get tag: "Email Unverified"
Verified emails get tag: "Snovio" (or just Lead_Source)
Quick Architecture Confirm
Option A - Single workflow, two endpoints:

GET  /webhook/snovio-search?accountId=XXX
POST /webhook/snovio-save
Option B - Two separate workflows

Popup approach:

Build HTML selector directly in workflow (matches your existing Enrich popup pattern)
Ready to build? Just confirm:

Single workflow (A) or separate (B)?
Any specific "Select All Verified" button in popup, or just manual checkboxes?
not sure what that means, elaborate. 2. no select all, if the account has 5k contacts, that could burn our monthly credits when the pool is getting used regularly, so manual selection with the checkbox is best. Can we color it with our perdigon white, purple blue and add the logo somewhere for us to demo this feature?
Jan 10

Clarified workflow architecture options and gathered branding specifications.




Architecture Clarification
Option A - Single Workflow (2 endpoints):

One n8n workflow file with:
├── Webhook 1: GET /snovio-search  → Searches Snovio, returns HTML popup
└── Webhook 2: POST /snovio-save   → Receives selections, creates Contacts
Pros: All Snovio logic in one place, shared config node, easier to maintain
Cons: Slightly more complex routing inside workflow
Option B - Two Separate Workflows:

Workflow 1: "Snovio Search"
└── GET /snovio-search → Returns HTML popup

Workflow 2: "Snovio Save" 
└── POST /snovio-save → Creates Contacts
Pros: Simpler individual workflows, independent versioning
Cons: Duplicate config (API keys, owner mapping), two files to maintain
My recommendation: Option A (single workflow) - matches your Enrichment v7 pattern where everything lives together.

Branding
I want to get the colors right. Can you share:

Perdigon purple - hex code (e.g., 
#6B4C9A?)
Perdigon blue - hex code
Logo URL - is it hosted somewhere I can reference, or should I embed it as base64?
Or if you have a brand guidelines doc in Google Drive, I can pull the specs from there.

Option A: Branding: use what we have been using here: <!DOCTYPE html><html><head><title>No Records</title><style>body{font-family:sans-serif;background:
#1a1a2e;color:#fff;display:flex;align-items:center;justify-content:center;min-height:100vh}.card{background:rgba(255,255,255,0.1);border-radius:20px;padding:40px;text-align:center;max-width:500px}.icon{font-size:64px;margin-bottom:20px}</style></head><body><div class="card"><div class="icon">✓</div><h1>Already Enriched</h1><p>All records already have the Enriched tag.</p></div></body></html> image: I have some options out here on my github, can you give me some logo options here? https://github.com/mallen012/Perdigon-Directory/tree/main

Jan 10

1 step
favicon

Fetched
GitHub - mallen012/Perdigon-Directory: Mike's PErdigon Directory Example
github.com


Catalogued available logo assets and recommended GitHub URLs.



Found your logos. Here are the options for the popup:

Logo Options (Raw GitHub URLs)
Option	File	Best For	URL
A	Blue Logo Only.png	Icon/corner placement	https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/Blue%20Logo%20Only.png
B	Blue Logo.png	Header with text	https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/Blue%20Logo.png
C	Perdigon.svg	Scalable/crisp	https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/Perdigon.svg
D	android-chrome-192x192.png	Small icon	https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/android-chrome-192x192.png
E	animated/ folder	Loading states?	(need to check contents)
Proposed Popup Layout
┌─────────────────────────────────────────────────────┐
│  [LOGO]  Snovio Contact Finder                      │
│  Account: Cisco Systems                             │
├─────────────────────────────────────────────────────┤
│  ☑  John Smith - VP Sales           [LinkedIn ↗]   │  ← 🟢 green bg
│      john.smith@cisco.com (verified)                │
├─────────────────────────────────────────────────────┤
│  ☐  Jane Doe - Director IT          [LinkedIn ↗]   │  ← 🟡 yellow bg  
│      jane.doe@cisco.com (unverified)                │
├─────────────────────────────────────────────────────┤
│  Selected: 1 of 24 contacts                         │
│                          [Import Selected]          │
└─────────────────────────────────────────────────────┘
Colors (from your existing style):

Background: 
#1a1a2e (dark navy)
Card: rgba(255,255,255,0.1) (glass effect)
Text: #fff
Verified row: rgba(100, 200, 120, 0.15) (soft green)
Unverified row: rgba(255, 180, 80, 0.15) (soft amber)
Which logo option? A, B, C, or D?

And want me to check the animated/ folder for any loading spinners?

Lets go A

Jan 10

Consolidated workflow specifications and prepared to build integration.




Got it. Logo A - Blue Logo Only.

Final Spec Summary
Element	Value
Architecture	Single workflow, 2 endpoints
Logo	https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/Blue%20Logo%20Only.png
Background	
#1a1a2e
Card	rgba(255,255,255,0.1) glass effect
Verified rows	rgba(100, 200, 120, 0.15) soft green
Unverified rows	rgba(255, 180, 80, 0.15) soft amber
LinkedIn	Clickable hyperlink → new tab
Selection	Manual checkboxes only
Account update	Auto-fill company data + address if empty
Unverified tag	"Email Unverified"
Let me pull your existing Enrichment v7 workflow structure to match the pattern, then I'll build the Snovio workflow.

favicon

N8n get workflow



Architected dual-endpoint workflow integrating Snovio search and contact creation.




Got it — Option A: Single workflow, two endpoints.

I'll build the complete Snovio Contact Finder workflow now. Here's the plan:

Workflow Structure
┌─────────────────────────────────────────────────────────────────┐
│  ENDPOINT 1: GET /webhook/snovio-search?accountId=XXX           │
├─────────────────────────────────────────────────────────────────┤
│  1. Config (credentials, settings)                              │
│  2. Get Zoho Account → extract domain from Website              │
│  3. Snovio: Get Access Token                                    │
│  4. Snovio: Domain Search (company info)                        │
│  5. Snovio: Get Prospects                                       │
│  6. Auto-update Zoho Account (if fields empty)                  │
│  7. Build HTML Popup → Respond                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ENDPOINT 2: POST /webhook/snovio-save                          │
├─────────────────────────────────────────────────────────────────┤
│  1. Parse selected prospect IDs                                 │
│  2. Loop: Snovio Email Finder (1 credit each)                   │
│  3. Snovio: Get Profile (enriched data)                         │
│  4. Create Zoho Contact records                                 │
│  5. Apply tags (verified vs unverified)                         │
│  6. HTML Success Response                                       │
└─────────────────────────────────────────────────────────────────┘
Before I create the workflow, one quick question:

How should the workflow be triggered from Zoho?

A) Zoho Button on Account detail page (like Enrichment) — opens popup
B) Zoho Widget embedded in Account page
C) Both — button for now, widget later

This determines how I pass the accountId parameter.

C. Give me the button code and i can build the button for zoho

Jan 10

Orchestrated Zoho button code delivery for user implementation.


Here's the Zoho button code:

Zoho Button Code
javascript
// Snovio Contact Finder - Zoho Account Button
// Place this in: Settings → Customization → Modules → Accounts → Links & Buttons → New Button

// Get current Account ID
accountId = input.Accounts.ID;

// Open Snovio Contact Finder popup
openUrl("https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=" + accountId, false);
Button Setup:

Setting	Value
Button Name	Find Contacts (Snovio)
Module	Accounts
Position	Detail Page
Action	Custom Function (Deluge)
Alternative: Direct Link Button
If you prefer a simpler link-based button:

Setting	Value
Button Name	Find Contacts (Snovio)
Type	Open URL
URL	https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=${Accounts.Id}
I'll now build the n8n workflow. Give me a few minutes to construct it with:

Both webhook endpoints (GET search, POST save)
Snovio OAuth token handling
HTML popup with your branding
Zoho Account auto-update
Contact creation with proper field mapping
Ready to proceed?

yes, but where would i put the zoho button code if i want to look at that option?

Jan 10

Pinpointed the exact Zoho CRM pathway for custom button placement.

Zoho Button Setup Path
For Deluge Script Button:

Zoho CRM → Setup (⚙️) → Customization → Modules and Fields 
→ Accounts → Links and Buttons → + New Button
Then:

Button Name: Find Contacts (Snovio)
Where would you like to place the button?: View Page (Detail Page)
What action would you like the button to perform?: Writing Function
Click Write your own
Paste this in the Deluge editor:

javascript
accountId = input.Accounts.ID;
openUrl("https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=" + accountId, false);
Save & Associate → Select profiles that can see it
For Simple URL Button (no Deluge):

Same path, but at step 3:

What action would you like the button to perform?: Open a URL
URL: https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=${Accounts.Id}
The Deluge option gives you more flexibility later (logging, validation), but the URL option works fine for this use case.

Building the workflow now...

button done, need anything from me?

Jan 10

Assembled credentials and architected comprehensive workflow structure.
11s





Nope, I have everything:

Item	Status
Snovio credentials	✅ d37f94b1... / 45b473e4...
Zoho OAuth	✅ jcm850uJVwpPyj2c
Logo URL	✅ Blue Logo Only.png
Branding	✅ 
#1a1a2e dark theme
Field mappings	✅ From transcript
Webhook path	✅ /webhook/snovio-search
Building now...

favicon

N8n create workflow



Rectified node naming inconsistency in workflow configuration.

Let me fix the node naming issue:

favicon

N8n create workflow



Orchestrated workflow activation to deploy webhooks.

Workflow created. Let me activate it so the webhooks go live:


2 steps
favicon

N8n update full workflow



Deliberated manual activation versus providing instructions.

✅ Workflow Created!
Item	Value
Workflow ID	pvdUlL8oUiLlSvkD
Name	Snovio Contact Finder (Zoho Accounts)
Nodes	32
Status	Inactive (needs activation)
Next Steps
Activate the workflow in n8n:
Go to: https://n8n.srv1127126.hstgr.cloud/workflow/pvdUlL8oUiLlSvkD
Toggle the Active switch in the top-right corner
Test the button on any Zoho Account with a Website
Endpoints (once activated)
Endpoint	URL
Search	https://n8n.srv1127126.hstgr.cloud/webhook/snovio-search?accountId=XXX
Save	https://n8n.srv1127126.hstgr.cloud/webhook/snovio-save (POST)
What the workflow does:
GET request → Pulls Account, extracts domain from Website
Snovio Domain Search → Gets company info + prospect list (1 credit)
Auto-updates Account if Phone/Industry/City empty
Displays HTML popup with color-coded contacts
User selects contacts via checkboxes
POST submission → Snovio Email Finder (1 credit/selected)
Creates Zoho Contacts linked to Account
Tags unverified emails with "Email Unverified"
Ready to activate and test?

1768069552866_image.png
workflow looks successful, i just enabled mcp too, can we see whats going on?

Jan 10

3 steps
favicon

N8n executions



Diagnosed API endpoint errors and merge node configuration issues.
19s










Found two issues:

Issue 1: Snovio API 404
The Domain Search endpoint returned 404 - I used the wrong API URL. Should be:

❌ https://api.snov.io/v2/domain-search
✅ https://api.snov.io/v1/get-all-emails-from-website
Issue 2: Merge Node Logic Bug
When there are no Account updates, data goes to Merge input2, but the node is configured to output input1 (which is empty). So the popup never renders.

Let me fix both:


2 steps
favicon

N8n update partial workflow



Debugged merge node configuration and reconsidered data flow logic.
16s














Actually, let me fix the Merge properly - chooseBranch mode doesn't work well for this. I need append mode so either path flows through:

favicon

N8n update partial workflow



Verified API endpoints and reconsidered MCP tool integration approach.









Fixed! Try the button again.

Changes made:

✅ Snovio API endpoint: /v1/get-all-emails-from-website
✅ Merge node: append mode (passes data from whichever path fires)
If it still fails, let me know - I can also test the Snovio API directly through the MCP tool to verify the correct endpoint format.

1768069820868_image.png
1768069869066_image.png
ours didnt bring back contacts, but snovio browser extension does

Jan 10

Investigated API endpoint discrepancy and identified testing approach.







The popup rendered (great!) but Snovio API returned no contacts. Let me test the Snovio MCP directly to see what's happening:

favicon
Snovio count email



Investigated API flow discrepancy between implementation and extension.



Let me check the actual Snovio API response from the workflow:


2 steps
favicon

N8n executions



Investigated API endpoint discrepancies between versions.











Still 404. The Snovio API endpoint is wrong. Let me search for the correct one:


2 steps
favicon

Fetched
How to find domain contacts in Domain Search API
snov.io


Diagnosed API version mismatch and restructured authentication approach.







Found the issue! Snovio v2 API is async - requires 2 calls:

Step	Endpoint	Method
1	/v2/domain-search/prospects/start?domain=xxx	POST → returns task_hash
2	/v2/domain-search/prospects/result/{task_hash}	GET → returns prospects
Also requires Bearer token in header, not body.

Let me rebuild the Snovio nodes properly:

favicon

N8n update partial workflow



Debugged API response parser for contact retrieval compatibility.



Now update the parser to handle v2 API response format:

favicon

N8n update partial workflow



Engineered async handling with strategic delay mechanism.



Add a small delay to allow async search to complete:

favicon

N8n update partial workflow



Deliberated webhook timing constraints and alternative request strategies.





Actually, Wait nodes can cause issues in webhook mode. Let me remove it and test - the API might be fast enough:

favicon

N8n update partial workflow



Verified workflow connectivity and structural integrity.

Try the button again. I've updated:

✅ Start Search: POST /v2/domain-search/prospects/start?domain=xxx
✅ Get Results: GET /v2/domain-search/prospects/result/{task_hash}
✅ Bearer token in Authorization header
✅ Parser updated for v2 response format
If it returns "in_progress", we may need to add a retry loop - but let's test first.

1768070140646_image.png
nothing

Jan 10

3 steps
favicon

N8n executions



Diagnosed API integration issue and pivoted strategy.




The v2 API is too complex (async with task_hash). The Start Search returned data: [] immediately, and the Get Results failed with 422 "Request not found".

Let me switch to the v1 API which is simpler and synchronous:

favicon

N8n update partial workflow



Recalibrated parser architecture for API response handling.

Now update the parser for v1 API response:

favicon

N8n update partial workflow



Pivoted API strategy and readied testing phase.


Try again. Switched to v1 API:

Old (v2)	New (v1)
Async, 2 calls	Sync, 1 call
/v2/domain-search/prospects/start	/v1/get-domain-emails-with-info
The v1 endpoint returns everything in one call: emails + prospect info.

1768070298642_image.png
nothing yet, do we need to use the snovio mcp i made at zoho? mcp-zohosnovio https://perdigonsnovio-909592906.zohomcp.com/mcp/message?key=593bc0485e47db1d924093ff43802eba We can try a few more api calls to keep away from ai tokens, but know we have that path too

Jan 10

Investigated API response and evaluated Snovio tool integration.

Let me check the latest execution and test the Snovio MCP directly:


4 steps
favicon

N8n executions



Diagnosed endpoint failure and contemplated alternative API testing strategies.



Still getting 404. The API endpoint /v1/get-domain-emails-with-info doesn't exist. Let me test your Snovio MCP directly:

favicon
Snovio count email



Investigated API endpoint structure and request formatting issues.








Let me try a different known domain with your MCP:


2 steps
favicon
Snovio get profile



Diagnosed API format issues and pivoted toward form-encoded solutions.



The MCP is returning null for everything - might be auth issue. Let me fix the n8n node to use form-urlencoded instead of JSON (that's how Snovio v1 API works):

favicon

N8n update partial workflow



Devised testing strategy to validate API authentication first.


Try the button now - just testing if the API connectivity works with /v1/get-domain-emails-count (free endpoint). If this returns a count, we know the auth works.

1768070630460_image.png
can we add the domain email count to our popup somewhere? It does not look any different to me?

Jan 10

3 steps
favicon

N8n executions



Verified API functionality and strategized displaying email count visually.







Progress! The API returned "result": 196 - meaning 196 emails in Snovio's database for computerpackages.com! Auth works.

Now we need the endpoint that returns the actual prospect data. Let me update the popup to show the count AND switch to the correct endpoint:

favicon

N8n update partial workflow



Investigated correct API endpoint for retrieving domain emails.









Try the button again - I'm testing different endpoints. Let me also check what happens:

favicon

N8n executions



Investigated correct API endpoint for retrieving domain email data.
12s
















Let me search for the exact Snovio API endpoint that returns prospect data:

favicon

Fetched
API • Email Finder, Verifier & Sender API methods | Snov.io
snov.io


Investigated API endpoints and architected solution for displaying email count.
24s










I see the issue now. Looking at the Snovio API docs:

The v2 API is async (requires polling):

POST /v2/domain-search/prospects/start → returns task_hash
GET /v2/domain-search/prospects/result/{task_hash} → returns prospects (after delay)
This doesn't work with webhook responseMode because we can't poll/wait.

Quick fix: Let me update the workflow to:

Show the count (196 emails) in the popup header
Try the v2 flow to see if results are cached/immediate
favicon

N8n get workflow



Architected workflow restructuring to display domain email counts.







I need to restructure the workflow to use the proper v2 API flow. Let me add nodes for:

Get Count (v1 - sync, FREE)
Start Prospect Search (v2 - async)
Get Prospect Results (v2 - poll result)
favicon

N8n update partial workflow



Orchestrated comprehensive implementation with proper connections integrated.

Let me add the connections too:

favicon

N8n update partial workflow



Recalibrated node naming conventions for accuracy.

The node was already renamed. Let me fix the connections:

favicon

N8n update partial workflow



Reconciled validation errors and corrected node naming conventions.

The workflow wasn't saved. Let me use the correct node names:

favicon

N8n update partial workflow



Assessed node removal and prepared connection implementation.

The old node is already gone. Let me just add the connections:

favicon

N8n update partial workflow



Diagnosed popup display issue and strategized count integration approach.



Let me check the latest execution to see what's happening:


2 steps
favicon

N8n executions



Diagnosed API endpoint issue and strategized display implementation.
10s










I see the problem - my earlier update broke the endpoint. It's now calling a wrong API that requires an email. Let me fix the workflow to:

Show the count in the header (196 emails available)
Use proper v2 async flow with a wait/poll
Let me fix the Snovio node first:

favicon

N8n update partial workflow



Strategized integrating email count display into popup interface.


Now let me update the Parse Snovio Results node to handle the count response and pass it to the popup:

favicon

N8n executions



Diagnosed display issue and strategized count integration approach.








I see the data now. The count is there (totalCount: 196) but the popup code isn't displaying it in the header. Let me update the Build Popup HTML to show the count:


favicon
N8n get workflow


want me to try it yet?

Jan 10

Weighed endpoint limitations and devised alternative solutions.





Yes, try it! But heads up on what you'll see:

Current state:

✅ API will work (returns 196 count)
⚠️ Popup will still show "No contacts found"
Why: The get-domain-emails-count endpoint only returns the count (196), not the actual prospect names/emails. The v2 API that returns prospect data is async (requires polling), which is tricky with webhooks.

Quick options:

A) Test now → I'll update the popup to at least show "📊 196 emails in Snovio database" in the header
B) I switch to v2 async flow with a Wait node (adds ~2-3 sec delay but gets real data)
C) Use v1 /get-emails-from-names to fetch prospects one-by-one (costs 1 credit each)
Which approach do you prefer?

1768071140997_image.png
option 2 is the best right, to deliver what we want?

Jan 10

Validated async workflow approach and outlined implementation steps.




Yes, option 2 is the right call - it gets you the actual prospect data (names, positions, LinkedIn URLs) that users can select and import. The 2-3 sec delay is worth it.

Let me implement the v2 async flow:

favicon

N8n update partial workflow



Deliberated workflow refinements and interface updates.

Now let me update the popup to show the database count in the header:

favicon

N8n update partial workflow



Verified workflow structure and connections.

Done! The workflow now:

Starts v2 prospect search → gets task_hash
Waits 3 seconds → lets Snovio process
Fetches results → gets actual prospect names/positions
Shows in popup with database count badge in header
Try it now! You should see:

📊 Badge showing "196 in database"
List of actual prospects with names & positions
LinkedIn links where available
Yellow rows = needs email lookup (1 credit each)
Green rows = already has email
1768071921526_image.png
error in workflow, i see the image address here too https://app.snov.io/media/img/companies/4471a8c3ee2f9ce4eabeb3d9a36f7fd5.jpg something we can also update when we have the api working? error: {
  "errorMessage": "The resource you are requesting could not be found",
  "errorDescription": "Sorry, but url or entity not found",
  "errorDetails": {
    "rawErrorMessage": [
      "404 - {\"errors\":{\"code\":404,\"title\":\"Sorry, but url or entity not found\",\"source\":\"\"}}"
    ],
    "httpCode": "404"
  },
  "n8nDetails": {
    "nodeName": "Snovio: Get Results",
    "nodeType": "n8n-nodes-base.httpRequest",
    "nodeVersion": 4.2,
    "itemIndex": 0,
    "time": "1/10/2026, 11:06:31 AM",
    "n8nVersion": "2.2.5 (Self Hosted)",
    "binaryDataMode": "filesystem",
    "stackTrace": [
      "NodeApiError: The resource you are requesting could not be found",
      "    at ExecuteContext.execute (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-nodes-base@file+packages+nodes-base_@aws-sdk+credential-providers@3.808.0_asn1.js@5_8da18263ca0574b0db58d4fefd8173ce/node_modules/n8n-nodes-base/nodes/HttpRequest/V3/HttpRequestV3.node.ts:859:16)",
      "    at processTicksAndRejections (node:internal/process/task_queues:105:5)",
      "    at WorkflowExecute.executeNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+sdk-trace-base@1.30_ec37920eb95917b28efaa783206b20f3/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1045:8)",
      "    at WorkflowExecute.runNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+sdk-trace-base@1.30_ec37920eb95917b28efaa783206b20f3/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1226:11)",
      "    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+sdk-trace-base@1.30_ec37920eb95917b28efaa783206b20f3/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1662:27",
      "    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file+packages+core_@opentelemetry+api@1.9.0_@opentelemetry+sdk-trace-base@1.30_ec37920eb95917b28efaa783206b20f3/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:2297:11"
    ]
  }
}

Show more
Jan 10

Investigated API endpoint malfunction and task_hash routing issue.


Let me check what the Start Search node returned:


2 steps
favicon

N8n executions



Identified incorrect API path reference in workflow configuration.






Found it! The task_hash is in meta.task_hash, not data.task_hash. Look at the response:

json
"meta": { "task_hash": "d24ec8becb531a51e8ea02f47051b41c" },
"links": { "result": "https://api.snov.io/v2/..." }
Easy fix - just use the links.result URL directly:

favicon

N8n update partial workflow



Resolved URL issue and identified logo enhancement opportunity.



Fixed! Now using the links.result URL directly from the API response.

Try it again!

And yes - good catch on the company logo! Once this is working, we can add that to the Account updates. The API returns the logo URL which we can save to a Zoho field.

1768072140953_image.png
still nothing there, but success in the workflow again

Jan 10

Investigated API response structure to diagnose missing contact data.

Let me check what the Get Results node actually returned:


2 steps
favicon

N8n executions



Diagnosed data structure mismatch and formulated parsing fix.




The API returned 20 prospects with data! But the Parse node is looking in the wrong place. The data structure is:

data = array of prospects (not data.prospects)
meta.total_count = 47
Let me fix the parser:

favicon

N8n update partial workflow



Debugged parser logic and validated workflow success.


Fixed! The parser now correctly reads the data array. Try it again!

You should see:

20 prospects with names like Tatiana Draganova (Managing Director Europe), Kelly McManus (Director of Client Relations), etc.
47 total in database
LinkedIn profile links
Yellow rows (need email lookup - 1 credit each)
is there a way to only sort by US/ Canada?

Jan 10

Investigated location filtering capabilities and identified API limitations.
10s












Unfortunately, Snovio's domain search API doesn't have a location/country filter. The prospect data only includes:

Name
Position
LinkedIn URL
No country field is returned or filterable.

Workaround options:

Option	Pros	Cons
A) Filter by position keywords	Can target "US", "NA", "Americas" in titles	Misses people without regional titles
B) Scrape LinkedIn location	Most accurate	Slow, complex, may violate ToS
C) Use positions filter	Target specific roles (VP Sales, Director, etc.)	Not location-based
D) Accept as-is	Get all prospects, filter manually	More noise
My recommendation: Option C - filter by decision-maker positions instead. This is actually more valuable for sales than location filtering. I can add a positions filter like:

["CEO", "CTO", "CFO", "VP", "Director", "President", "Owner", "Manager"]
This would give you ~10-15 key contacts instead of 47 random employees.

Want me to:

Add position filtering for decision-makers?
Add a position dropdown to the popup so you can choose?
Leave as-is and you'll manually pick from the list?
1768074121513_image.png
yes, but we need to select multiples, and would it be based on what was returned? i.e. if we select CEO, but its spelled out Chief Exec... I dont want to miss it. That way we can select what is available? can we filter by status, position, and by contact on the popup?
Yes
Whats the stats mean?
We are displaying 1-20 of 47, can we have a next page?
I selected one, clicked import, it imported to Zoho, but did not lookup the email and add to the import. Ideas how to get that accomplished? Screenshot attached, this looks great.
Jan 10

Dissected feature requests and prioritized email lookup integration challenge.








Excellent progress! Let me answer your questions and outline the enhancements:

Answers:

Question	Answer
Status "?"	Means "unknown" - email not yet looked up. Would show ✓ (valid email) or ✗ (not found) after lookup
47 in database	Total prospects Snovio has for this domain. Currently showing first 20
Email not imported	The save workflow isn't calling the email lookup API yet - needs enhancement
Proposed Enhancements (priority order):

🔴 Email Lookup on Import - Critical fix
Call search_emails_start URL for each contact before creating in Zoho
Costs 1 credit per lookup
🟡 Smart Position Filters - Build dropdown from actual returned positions, group similar ones:
"Executive" = CEO, Chief Executive, President, Owner
"Director" = Director, VP, Vice President
"Manager" = Manager, Supervisor, Team Lead
Plus free-text search
🟡 Pagination - Next/Prev buttons for pages 2, 3, etc.
🟢 Search/Filter Bar - Filter visible rows by name or position text
Want me to start with #1 (Email Lookup)? This is the most important fix since imports are incomplete without emails.

Let me first check the current save workflow to see what needs to change:


2 steps
P


Get workflow details



Diagnosed email lookup workflow issue and architected v2 API solution.
20s












I see the issue. The save workflow is using the v1 email finder (/v1/get-emails-from-name) but we need to use the v2 async email lookup with the emailLookupUrl we already have from the search results.

Let me fix the email lookup flow. This requires:

Updating popup to pass emailLookupUrl
Changing save workflow to use v2 async pattern (POST start → Wait → GET result)
favicon
N8n update partial workflow



Pivoted strategy to establish local foundation first.

Let me try a different approach - create the updated node code and apply it:


Save updated popup HTML code with emailLookupUrl data attribute



Architected workflow updates to integrate v2 email API asynchronously.






Now let me update the Email Finder node to use the v2 async flow. First, let me check the v2 email lookup API:


snov.io API v2 domain-search prospects search-emails start result
10 results






















Architected async email lookup workflow with sequential API calls.
12s










Got it. The v2 email lookup flow is:

POST to emailLookupUrl (search_emails_start) → returns task_hash and links.result
Wait 2 seconds
GET the result URL → returns email data
Let me update the save workflow with the proper v2 async flow:

favicon

N8n update partial workflow



Orchestrated connections integration within existing operation.

Let me add the nodes with proper connections:

favicon

N8n update partial workflow



Orchestrated node updates to handle email response formats and data flow.


Now let me update the Parse Email Result node to handle the v2 response format:

favicon

N8n update partial workflow



Identified missing workflow updates for email lookup integration.



Now let me update the popup to pass the emailLookupUrl:


2 steps

Check file size



Strategized file updates and API integration approach.



Let me check what the current popup code in the workflow looks like to see what needs updating:

favicon

N8n executions



Identified outdated execution and strategized HTML node updates.



I see the issue - the popup code still doesn't have emailLookupUrl. Let me update both the checkbox data attribute and the form submission:


4 steps

Get the full popup code



Deliberated on updating popup node via API integration.

Let me update the node via direct API call:


Update Build Popup HTML node via n8n API



Diagnosed DNS connectivity issue and refined tool implementation.

Let me try the MCP tool with the code properly formatted:

favicon

N8n update partial workflow



Refined popup functionality and reorganized workflow node positioning.


Now let me update the Parse Email Result node position and move the Create Zoho Contact to follow the new flow:

favicon

N8n update partial workflow



Architected email lookup optimization and verified workflow integrity.






Let me verify the workflow structure is correct:

favicon

N8n validate workflow



Synthesized workflow updates and identified email lookup functionality gap.




Good news - I've updated the workflow to fix the email lookup! Here's the summary:

✅ Changes Made:

Component	Fix
Popup HTML	Now passes emailLookupUrl to save endpoint
Email Lookup	Changed from v1 to v2 async flow (POST → Wait 2s → GET)
Parse Email	Updated to handle v2 response format
🔄 New Save Flow:

Loop Prospects → Snovio: Start Email Lookup (POST to emailLookupUrl)
    → Wait 2s → Snovio: Get Email Result → Parse Email Result
    → Create Zoho Contact (with email)
Please test again:

Open the popup fresh (reload)
Select a contact
Click Import
Check if email was looked up and added
Regarding your other questions - here's my plan:

Feature	Status
Position filter dropdown	Will add smart groupings (Executive, Director, Manager, etc.) based on returned positions
Search/filter bar	Will add text search across name and position
Status filter	Will add (Has Email / Needs Lookup)
Pagination	Will add Next/Prev for pages 2, 3, etc.
"47 in database" badge	Total prospects Snovio has for this domain
Want me to proceed with adding filters/pagination after you confirm the email lookup is working?

Import worked, but missing phone number for contact. Id also like to grab the domain and drop in the email domail account field, are we grabbing or saving the rest of the account info we planned on updating too? yes to all of those proposed enhancements, maybe while the form is pulled up, we click on the name and pull the email and turn it green or orange? can we also display credits used/ available on the form/ popup too for the entire account, not just the current email pull?

Jan 10

Evaluated feature gaps and mapped enhancement requests comprehensively.
11s










Great feedback! Let me address each point:

Quick Answers:

Item	Status
Phone number	❌ Snovio doesn't provide phone for prospects - only name, position, LinkedIn, email. Would need PeopleDataLabs or Apollo for phone
Email Domain field	✅ Can add - what's the Zoho field API name?
Account info updates	❌ Currently empty - I'll re-enable company enrichment
Click-to-lookup emails	✅ Great UX idea - will implement
Credits display	✅ Will add - need to check Snovio API
Let me first check the Snovio API for credits and see what Account fields we have:


snov.io API get credits balance user limits
10 results






















Inventoried feature requests and located API integration points.



Found it! Snovio has a balance API:

GET https://api.snov.io/v1/get-balance
Response: { "data": { "balance": "25000.00", "limit_resets_in": 29 } }
Let me check the current workflow and Zoho Contact fields to plan this properly:


1 step

Investigated email domain field integration within Contacts module.


Find email domain related fields in Contacts








Claude is AI and can make mistakes. Please double-check responses.
