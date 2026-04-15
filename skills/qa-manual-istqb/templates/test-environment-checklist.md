# Test Environment Checklist - {{project}}

> Use this checklist to verify test environment readiness before test execution begins.

## Document Control

- Project: {{project}}
- Release: {{release}}
- Environment: [Dev / QA / Staging / UAT / Pre-Prod]
- Date: {{date}}
- Verified by: {{owner}}

---

## 1. Infrastructure Readiness

### Servers and Services

| Item | Expected | Verified | Notes |
|------|----------|:--------:|-------|
| Application server running | [URL/endpoint] | [ ] | |
| Database server accessible | [Host:port] | [ ] | |
| API endpoints responding | [Base URL] | [ ] | |
| Message queue operational | [Service name] | [ ] | |
| Cache service running | [Service name] | [ ] | |
| File storage accessible | [Path/bucket] | [ ] | |

### Network and Connectivity

| Item | Expected | Verified | Notes |
|------|----------|:--------:|-------|
| VPN connection (if required) | [VPN details] | [ ] | |
| Firewall rules configured | [Ports open] | [ ] | |
| SSL certificates valid | [Expiry date] | [ ] | |
| DNS resolution working | [Domains] | [ ] | |

---

## 2. Application Deployment

| Item | Expected | Verified | Notes |
|------|----------|:--------:|-------|
| Correct build deployed | Build: [version/tag] | [ ] | |
| Configuration file correct | [Environment] | [ ] | |
| Feature flags set | [List flags] | [ ] | |
| Integrations configured | [List integrations] | [ ] | |
| Logging enabled | [Log level] | [ ] | |
| Monitoring active | [Dashboard URL] | [ ] | |

---

## 3. Test Data

### Database State

| Item | Expected | Verified | Notes |
|------|----------|:--------:|-------|
| Database schema current | Migration [version] | [ ] | |
| Seed data loaded | [Dataset name] | [ ] | |
| Test accounts created | [List accounts] | [ ] | |
| Reference data populated | [Data types] | [ ] | |

### Test Accounts

| Account Type | Username | Password | Role | Status |
|--------------|----------|----------|------|:------:|
| Admin | [username] | [stored securely] | Administrator | [ ] Verified |
| Standard User | [username] | [stored securely] | User | [ ] Verified |
| Guest | [username] | [stored securely] | Guest | [ ] Verified |
| [Custom role] | [username] | [stored securely] | [Role] | [ ] Verified |

### External Test Data

| Data Type | Source | Refresh Date | Notes |
|-----------|--------|--------------|-------|
| Customer records | [Source] | [Date] | |
| Product catalog | [Source] | [Date] | |
| Transaction history | [Source] | [Date] | |

---

## 4. Test Tools

### Automation Tools

| Tool | Version | Status | Configuration |
|------|---------|:------:|---------------|
| Playwright | [version] | [ ] Installed | [config file] |
| Node.js | [version] | [ ] Installed | |
| Browser drivers | [versions] | [ ] Updated | |
| Test reporter | [name] | [ ] Configured | |

### Supporting Tools

| Tool | Purpose | Status | Access Verified |
|------|---------|:------:|:---------------:|
| Test management | [Jira/TestRail/etc.] | [ ] Accessible | [ ] |
| Defect tracker | [Jira/etc.] | [ ] Accessible | [ ] |
| CI/CD pipeline | [Jenkins/GitHub Actions/etc.] | [ ] Running | [ ] |
| Log aggregator | [Splunk/ELK/etc.] | [ ] Accessible | [ ] |
| API client | [Postman/Insomnia] | [ ] Configured | [ ] |

---

## 5. Browser/Device Coverage

### Desktop Browsers

| Browser | Version | OS | Status |
|---------|---------|-----|:------:|
| Chrome | [latest] | Windows/Mac | [ ] |
| Firefox | [latest] | Windows/Mac | [ ] |
| Safari | [latest] | Mac | [ ] |
| Edge | [latest] | Windows | [ ] |

### Mobile Devices (if applicable)

| Device | OS Version | Browser | Status |
|--------|------------|---------|:------:|
| iPhone | iOS [version] | Safari | [ ] |
| Android | [version] | Chrome | [ ] |
| Tablet | [OS version] | [Browser] | [ ] |

---

## 6. Access and Permissions

| Resource | Required Access | Granted To | Verified |
|----------|----------------|------------|:--------:|
| Test environment URL | Read/Write | Test team | [ ] |
| Database (read-only) | Read | Test team | [ ] |
| Log files | Read | Test team | [ ] |
| CI/CD trigger | Execute | Test lead | [ ] |
| Defect tracker | Create/Edit | Test team | [ ] |
| Test management tool | Full access | Test team | [ ] |

---

## 7. Third-Party Integrations

| Integration | Endpoint | Mock/Stub/Live | Status | Notes |
|-------------|----------|----------------|:------:|-------|
| Payment gateway | [URL] | Mock | [ ] | Use test cards |
| Email service | [URL] | Stub | [ ] | Capture to test inbox |
| SMS provider | [URL] | Mock | [ ] | |
| OAuth provider | [URL] | Live (test tenant) | [ ] | |
| Analytics | [URL] | Disabled | [ ] | |

---

## 8. Environment Constraints and Limitations

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Data refresh schedule | [Impact] | [Mitigation] |
| Shared environment | [Impact] | [Coordinate with team] |
| Rate limits | [Impact] | [Adjust test pace] |
| Downtime windows | [Impact] | [Schedule around] |

---

## 9. Smoke Test Verification

Run basic smoke tests to confirm environment is functional:

| Test | Expected Result | Actual Result | Pass/Fail |
|------|-----------------|---------------|:---------:|
| Application loads | Home page displayed | | [ ] |
| User can log in | Dashboard shown | | [ ] |
| Database connectivity | Data retrieved | | [ ] |
| API health check | 200 OK | | [ ] |
| Create basic record | Record saved | | [ ] |

---

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Test Lead | | | |
| Environment Owner | | | |
| DevOps | | | |

---

## Notes and Issues

- **Blockers identified:**
- **Workarounds needed:**
- **Follow-up actions:**

---

## Revision History

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 0.1 | {{date}} | {{owner}} | Initial checklist |
