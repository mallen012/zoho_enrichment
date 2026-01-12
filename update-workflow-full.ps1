# Read the workflow
$workflow = Get-Content 'workflow-backup.json' -Raw | ConvertFrom-Json

# Find and update each node
foreach ($node in $workflow.nodes) {

    # 1. Update Parse Account - add currentEmailDomain
    if ($node.id -eq 'parse-account') {
        $node.parameters.jsCode = @'
const response = $input.first().json;
const config = $('Config (Search)').first().json;

const account = response.data?.[0];
if (!account) {
  return [{ json: { error: 'Account not found', accountId: config.ACCOUNT_ID } }];
}

// Extract domain from website
let domain = null;
if (account.Website) {
  try {
    let url = account.Website;
    if (!url.startsWith('http')) url = 'https://' + url;
    domain = new URL(url).hostname.replace('www.', '');
  } catch (e) {
    // Try simple extraction
    domain = account.Website.replace(/^(https?:\/\/)?(www\.)?/, '').split('/')[0];
  }
}

return [{ json: {
  ...config,
  accountId: account.id,
  accountName: account.Account_Name || '',
  website: account.Website || null,
  domain: domain,
  currentPhone: account.Phone || null,
  currentIndustry: account.Industry || null,
  currentEmployees: account.No_of_Employees || null,
  currentStreet: account.Billing_Street || null,
  currentCity: account.Billing_City || null,
  currentState: account.Billing_State || null,
  currentZip: account.Billing_Code || null,
  currentCountry: account.Billing_Country || null,
  currentEmailDomain: account.Email_Domain || null
}}];
'@
        Write-Host "Updated: Parse Account (added currentEmailDomain)"
    }

    # 2. Update Parse Snovio Results - add Email_Domain to accountUpdates
    if ($node.id -eq 'parse-snovio-results') {
        $node.parameters.jsCode = @'
const snovio = $input.first().json;
const accountData = $('Parse Account').first().json;

// Get credits balance from Snovio: Get Balance node
const creditsData = $('Snovio: Get Balance').first().json;
const creditsBalance = creditsData.balance || 0;

// v2 API response: data[] is the array of prospects, meta.total_count is the total
const rawProspects = snovio.data || [];
const totalCount = snovio.meta?.total_count || rawProspects.length;

const prospects = rawProspects.map((p, idx) => {
  // Check if Snovio already has cached email for this prospect
  const cachedEmail = p.emails?.emails?.[0]?.email || null;
  const cachedStatus = p.emails?.emails?.[0]?.smtp_status || null;

  // Extract prospect hash from search_emails_start URL (if present)
  const emailUrl = p.search_emails_start || '';
  const hashMatch = emailUrl.match(/start\/([a-f0-9]+)$/);
  const prospectHash = hashMatch ? hashMatch[1] : null;

  // Determine email and status
  let email = null;
  let status = 'unknown';

  if (cachedEmail) {
    // Snovio already has the email cached - use it directly
    email = cachedEmail;
    status = cachedStatus || 'valid';
  } else if (p.email) {
    // Direct email field (legacy format)
    email = p.email;
    status = 'valid';
  }

  return {
    id: prospectHash || `prospect-${idx}`,
    firstName: p.first_name || '',
    lastName: p.last_name || '',
    fullName: `${p.first_name || ''} ${p.last_name || ''}`.trim() || 'Unknown',
    position: p.position || '',
    email: email,
    sourcePage: p.source_page || null,
    status: status,
    prospectHash: prospectHash,
    emailLookupUrl: p.search_emails_start || null,
    hasCachedEmail: !!cachedEmail
  };
});

// Company info from Snovio meta
const meta = snovio.meta || {};
const companyInfo = {
  companyName: meta.company_name || null,
  website: accountData.domain,
  logoUrl: meta.logo || null,
  phone: meta.hq_phone || null,
  industry: meta.industry || null,
  city: meta.city || null,
  state: meta.state || null,
  country: meta.country || null,
  street: meta.street || null,
  postalCode: meta.postal_code || null,
  employeeCount: meta.employee_count || null
};

// Build update fields for Account (only if currently empty in Zoho)
const accountUpdates = {};

// Phone
if (!accountData.currentPhone && meta.hq_phone) {
  accountUpdates.Phone = meta.hq_phone;
}

// Industry
if (!accountData.currentIndustry && meta.industry) {
  accountUpdates.Industry = meta.industry;
}

// Billing Address fields
if (!accountData.currentStreet && meta.street) {
  accountUpdates.Billing_Street = meta.street;
}
if (!accountData.currentCity && meta.city) {
  accountUpdates.Billing_City = meta.city;
}
if (!accountData.currentState && meta.state) {
  accountUpdates.Billing_State = meta.state;
}
if (!accountData.currentZip && meta.postal_code) {
  accountUpdates.Billing_Code = meta.postal_code;
}
if (!accountData.currentCountry && meta.country) {
  accountUpdates.Billing_Country = meta.country;
}

// Employee count
if (!accountData.currentEmployees && meta.employee_count) {
  accountUpdates.Employees = meta.employee_count;
}

// Email Domain - add domain to account if not already set
if (!accountData.currentEmailDomain && accountData.domain) {
  accountUpdates.Email_Domain = accountData.domain;
}

return [{ json: {
  ...accountData,
  companyInfo,
  prospects,
  prospectCount: prospects.length,
  totalCount: totalCount,
  hasMorePages: !!snovio.links?.next,
  accountUpdates,
  hasUpdates: Object.keys(accountUpdates).length > 0,
  apiSuccess: snovio.status === 'completed' || rawProspects.length > 0,
  creditsBalance: creditsBalance
}}];
'@
        Write-Host "Updated: Parse Snovio Results (added Email_Domain to accountUpdates)"
    }

    # 3. Update Build Popup HTML - add companyPhone hidden field and include in POST
    if ($node.id -eq 'build-popup-html') {
        $node.parameters.jsCode = @'
const data = $('Parse Snovio Results').first().json;
const prospects = data.prospects || [];
const accountName = data.accountName || 'Account';
const domain = data.domain || '';
const logoUrl = data.LOGO_URL;
const totalInDb = data.totalCount || 0;
const creditsBalance = data.creditsBalance || 0;
const companyPhone = data.companyInfo?.phone || '';
const companyWebsite = data.companyInfo?.website || domain;

let rows = '';
if (prospects.length === 0) {
  rows = '<tr><td colspan="5" style="text-align:center;padding:40px;color:#94a3b8;">' +
    (totalInDb > 0 ? '<div style="font-size:48px;margin-bottom:16px;">📊</div><div style="font-size:18px;margin-bottom:8px;">' + totalInDb + ' emails in Snovio database</div><div style="font-size:13px;">Prospect data is being processed. Try again in a moment.</div>' : 'No contacts found for this domain') +
    '</td></tr>';
} else {
  prospects.forEach((p, i) => {
    const hasEmail = p.email && p.email.length > 0;
    const rowBg = hasEmail ? 'rgba(100,200,120,0.15)' : 'rgba(255,180,80,0.15)';
    const statusIcon = hasEmail ? '✓' : '?';
    const statusColor = hasEmail ? '#4ade80' : '#fbbf24';
    const linkedInLink = p.sourcePage
      ? '<a href="' + p.sourcePage + '" target="_blank" style="color:#60a5fa;text-decoration:none;">LinkedIn 🔗</a>'
      : '<span style="color:#64748b;">—</span>';

    rows += '<tr style="background:' + rowBg + ';">' +
      '<td style="padding:12px;text-align:center;">' +
        '<input type="checkbox" name="prospect" value="' + p.id + '" ' +
          'data-firstname="' + (p.firstName || '').replace(/"/g, '&quot;') + '" ' +
          'data-lastname="' + (p.lastName || '').replace(/"/g, '&quot;') + '" ' +
          'data-position="' + (p.position || '').replace(/"/g, '&quot;') + '" ' +
          'data-email="' + (p.email || '').replace(/"/g, '&quot;') + '" ' +
          'data-linkedin="' + (p.sourcePage || '').replace(/"/g, '&quot;') + '" ' +
          'data-status="' + p.status + '" ' +
          'data-hash="' + (p.prospectHash || '') + '" ' +
          'data-emaillookupurl="' + (p.emailLookupUrl || '').replace(/"/g, '&quot;') + '" ' +
          'style="width:18px;height:18px;cursor:pointer;">' +
      '</td>' +
      '<td style="padding:12px;">' +
        '<div style="font-weight:500;">' + p.fullName + '</div>' +
        (p.email ? '<div style="font-size:12px;color:#94a3b8;">' + p.email + '</div>' : '<div style="font-size:12px;color:#fbbf24;">Email lookup required</div>') +
      '</td>' +
      '<td style="padding:12px;">' + linkedInLink + '</td>' +
      '<td style="padding:12px;color:#cbd5e1;">' + (p.position || '—') + '</td>' +
      '<td style="padding:12px;text-align:center;"><span style="color:' + statusColor + ';font-weight:bold;">' + statusIcon + '</span></td>' +
      '</tr>';
  });
}

const html = '<!DOCTYPE html><html><head><title>Snovio Contact Finder</title><style>*{box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#1a1a2e;color:#fff;margin:0;padding:20px;min-height:100vh}.container{max-width:900px;margin:0 auto}.header{display:flex;align-items:center;gap:16px;margin-bottom:24px;padding-bottom:16px;border-bottom:1px solid rgba(255,255,255,0.1)}.logo{height:40px}.header-content{flex:1}.title{font-size:24px;font-weight:600}.subtitle{color:#94a3b8;font-size:14px;margin-top:4px}.header-badges{display:flex;gap:10px;align-items:center}.credits-badge{background:linear-gradient(135deg,#10b981,#059669);padding:8px 16px;border-radius:20px;font-size:13px;font-weight:600}.db-count{background:linear-gradient(135deg,#6366f1,#8b5cf6);padding:8px 16px;border-radius:20px;font-size:13px;font-weight:600}.card{background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:16px;overflow:hidden}.table-container{overflow-x:auto;max-height:500px;overflow-y:auto}table{width:100%;border-collapse:collapse}th{background:rgba(0,0,0,0.3);padding:14px 12px;text-align:left;font-weight:600;font-size:12px;text-transform:uppercase;letter-spacing:0.5px;color:#94a3b8;position:sticky;top:0;z-index:10}th:first-child{text-align:center;width:50px}th:last-child{text-align:center;width:60px}tr{border-bottom:1px solid rgba(255,255,255,0.05)}tr:hover{background:rgba(255,255,255,0.05)!important}.footer{display:flex;justify-content:space-between;align-items:center;padding:16px 20px;background:rgba(0,0,0,0.2)}.count{color:#94a3b8;font-size:14px}.btn{background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border:none;padding:12px 24px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;transition:transform 0.2s,box-shadow 0.2s}.btn:hover{transform:translateY(-1px);box-shadow:0 4px 12px rgba(99,102,241,0.4)}.btn:disabled{opacity:0.5;cursor:not-allowed;transform:none}.legend{display:flex;gap:20px;margin-top:16px;font-size:13px;color:#94a3b8}.legend-item{display:flex;align-items:center;gap:6px}.legend-dot{width:12px;height:12px;border-radius:3px}.legend-verified{background:rgba(100,200,120,0.4)}.legend-unverified{background:rgba(255,180,80,0.4)}</style></head><body><div class="container"><div class="header"><img src="' + logoUrl + '" alt="Perdigon" class="logo"><div class="header-content"><div class="title">Snovio Contact Finder</div><div class="subtitle">' + accountName + ' • ' + domain + '</div></div><div class="header-badges"><div class="credits-badge">💳 ' + creditsBalance.toLocaleString() + ' credits</div>' + (totalInDb > 0 ? '<div class="db-count">📊 ' + totalInDb + ' in database</div>' : '') + '</div></div><form id="contactForm"><input type="hidden" name="accountId" value="' + data.accountId + '"><input type="hidden" name="accountName" value="' + accountName + '"><input type="hidden" name="domain" value="' + domain + '"><input type="hidden" name="companyPhone" value="' + companyPhone + '"><input type="hidden" name="companyWebsite" value="' + companyWebsite + '"><div class="card"><div class="table-container"><table><thead><tr><th>Select</th><th>Contact</th><th>Profile</th><th>Position</th><th>Status</th></tr></thead><tbody>' + rows + '</tbody></table></div><div class="footer"><div class="count"><span id="selectedCount">0</span> of ' + prospects.length + ' selected</div><button type="submit" class="btn" id="importBtn"' + (prospects.length === 0 ? ' disabled' : '') + '>Import Selected</button></div></div></form><div class="legend"><div class="legend-item"><div class="legend-dot legend-verified"></div><span>Has Email</span></div><div class="legend-item"><div class="legend-dot legend-unverified"></div><span>Needs Email Lookup (1 credit)</span></div></div></div><script>const form=document.getElementById("contactForm");const checkboxes=document.querySelectorAll("input[name=prospect]");const countEl=document.getElementById("selectedCount");const importBtn=document.getElementById("importBtn");function updateCount(){const selected=document.querySelectorAll("input[name=prospect]:checked").length;countEl.textContent=selected;importBtn.disabled=selected===0}checkboxes.forEach(cb=>cb.addEventListener("change",updateCount));form.addEventListener("submit",async(e)=>{e.preventDefault();importBtn.disabled=true;importBtn.textContent="Importing...";const selected=[];document.querySelectorAll("input[name=prospect]:checked").forEach(cb=>{selected.push({id:cb.value,firstName:cb.dataset.firstname,lastName:cb.dataset.lastname,position:cb.dataset.position,email:cb.dataset.email||null,linkedin:cb.dataset.linkedin,status:cb.dataset.status,prospectHash:cb.dataset.hash,emailLookupUrl:cb.dataset.emaillookupurl})});try{const response=await fetch("https://n8n.srv1127126.hstgr.cloud/webhook/snovio-save",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({accountId:form.querySelector("[name=accountId]").value,accountName:form.querySelector("[name=accountName]").value,domain:form.querySelector("[name=domain]").value,companyPhone:form.querySelector("[name=companyPhone]").value,companyWebsite:form.querySelector("[name=companyWebsite]").value,prospects:selected})});const html=await response.text();document.body.innerHTML=html}catch(err){alert("Error: "+err.message);importBtn.disabled=false;importBtn.textContent="Import Selected"}})</script></body></html>';

return [{ json: { html, prospectCount: prospects.length } }];
'@
        Write-Host "Updated: Build Popup HTML (added companyPhone, companyWebsite)"
    }

    # 4. Update Config (Save) - include companyPhone and companyWebsite
    if ($node.id -eq 'config-save') {
        $node.parameters.jsCode = @'
const body = $input.first().json.body || {};

const CONFIG = {
  SNOVIO_USER_ID: 'd37f94b18ce02ece5f401ce8683b258e',
  SNOVIO_SECRET: '45b473e4d2f48e928c9bafd7fcbcd853',
  ACCOUNT_ID: body.accountId || null,
  ACCOUNT_NAME: body.accountName || '',
  DOMAIN: body.domain || '',
  COMPANY_PHONE: body.companyPhone || '',
  COMPANY_WEBSITE: body.companyWebsite || '',
  SELECTED_PROSPECTS: body.prospects || [],
  LOGO_URL: 'https://raw.githubusercontent.com/mallen012/Perdigon-Directory/main/Blue%20Logo%20Only.png'
};

if (!CONFIG.ACCOUNT_ID || CONFIG.SELECTED_PROSPECTS.length === 0) {
  return [{ json: { error: 'Missing accountId or no prospects selected', CONFIG } }];
}

return [{ json: CONFIG }];
'@
        Write-Host "Updated: Config (Save) (added COMPANY_PHONE, COMPANY_WEBSITE)"
    }

    # 5. Update Prepare Prospects - include companyPhone and companyWebsite
    if ($node.id -eq 'prepare-prospects') {
        $node.parameters.jsCode = @'
const config = $('Config (Save)').first().json;
const token = $input.first().json.access_token;

return config.SELECTED_PROSPECTS.map(p => ({
  json: {
    ...p,
    accountId: config.ACCOUNT_ID,
    accountName: config.ACCOUNT_NAME,
    domain: config.DOMAIN,
    companyPhone: config.COMPANY_PHONE,
    companyWebsite: config.COMPANY_WEBSITE,
    accessToken: token
  }
}));
'@
        Write-Host "Updated: Prepare Prospects (added companyPhone, companyWebsite)"
    }

    # 6. Update Create Zoho Contact - add all new fields
    if ($node.id -eq 'create-zoho-contact') {
        $node.parameters.jsonBody = '={{ JSON.stringify({ data: [{ First_Name: $json.firstName || '''', Last_Name: $json.lastName || ''Unknown'', Email: $json.email || null, Title: $json.position || null, Phone: $json.companyPhone || null, LinkedIn_Contact_Profile_URL: $json.linkedin || null, Website: $json.linkedin || null, Account_Name: { id: $json.accountId }, Lead_Source: ''Snov.io'', Lead_Source_Perdigon: ''Snovio'', Enriched_Source: ''Snovio'', Snov_io_ID: $json.id || $json.prospectHash || null }], trigger: [''workflow''] }) }}'
        Write-Host "Updated: Create Zoho Contact (added Phone, Website, Lead_Source, Snov_io_ID)"
    }
}

# Convert back to JSON and save
$workflow | ConvertTo-Json -Depth 50 -Compress | Out-File 'workflow-updated.json' -Encoding UTF8

Write-Host "`nWorkflow updated and saved to workflow-updated.json"
Write-Host "Ready to push to n8n API"
