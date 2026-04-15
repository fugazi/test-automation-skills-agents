# Risk Assessment Matrix - {{project}}

> Product quality risk assessment for risk-based test prioritization.

## Document Control

- Project: {{project}}
- Release: {{release}}
- Date: {{date}}
- Author: {{owner}}
- Approvers: {{approvers}}

---

## Risk Scoring Guide

### Likelihood Scale (1-5)

| Score | Level | Description |
|:-----:|-------|-------------|
| 1 | Very Low | Rare occurrence (<10% chance) |
| 2 | Low | Unlikely (10-25% chance) |
| 3 | Medium | Possible (25-50% chance) |
| 4 | High | Likely (50-75% chance) |
| 5 | Very High | Almost certain (>75% chance) |

### Impact Scale (1-5)

| Score | Level | Description |
|:-----:|-------|-------------|
| 1 | Trivial | Cosmetic issue, easy workaround |
| 2 | Minor | Limited users affected, workaround exists |
| 3 | Moderate | Many users affected, difficult workaround |
| 4 | Major | Critical flow blocked, significant business impact |
| 5 | Critical | System down, data loss, safety/legal implications |

### Risk Level Matrix

|          | Impact 1 | Impact 2 | Impact 3 | Impact 4 | Impact 5 |
|----------|:--------:|:--------:|:--------:|:--------:|:--------:|
| **Likelihood 5** | 5 (M) | 10 (M) | 15 (H) | 20 (C) | 25 (C) |
| **Likelihood 4** | 4 (L) | 8 (M) | 12 (H) | 16 (H) | 20 (C) |
| **Likelihood 3** | 3 (L) | 6 (M) | 9 (M) | 12 (H) | 15 (H) |
| **Likelihood 2** | 2 (L) | 4 (L) | 6 (M) | 8 (M) | 10 (M) |
| **Likelihood 1** | 1 (L) | 2 (L) | 3 (L) | 4 (L) | 5 (M) |

**Legend:** L = Low (1-5) | M = Medium (6-12) | H = High (13-19) | C = Critical (20-25)

---

## Product Risk Register

### Functional Risks

| ID | Risk Description | Area/Feature | Likelihood | Impact | Score | Level | Mitigation Strategy |
|----|-----------------|--------------|:----------:|:------:|:-----:|:-----:|---------------------|
| FR-001 | Payment processing fails | Checkout | 3 | 5 | 15 | High | Extensive functional + integration testing |
| FR-002 | User data not saved correctly | Registration | 2 | 4 | 8 | Medium | Data validation + boundary testing |
| FR-003 | Search returns incorrect results | Search | 3 | 3 | 9 | Medium | EP/BVA + relevance testing |
| FR-004 | Session expires unexpectedly | Authentication | 2 | 3 | 6 | Medium | Session management testing |
| FR-005 | | | | | | | |

### Non-Functional Risks

| ID | Risk Description | Quality Attribute | Likelihood | Impact | Score | Level | Mitigation Strategy |
|----|-----------------|-------------------|:----------:|:------:|:-----:|:-----:|---------------------|
| NF-001 | Page load exceeds 3 seconds | Performance | 4 | 3 | 12 | High | Performance testing + monitoring |
| NF-002 | SQL injection vulnerability | Security | 2 | 5 | 10 | Medium | Security scanning + penetration testing |
| NF-003 | System crashes under load | Reliability | 3 | 4 | 12 | High | Load testing + stress testing |
| NF-004 | Inaccessible for screen readers | Accessibility | 3 | 3 | 9 | Medium | WCAG compliance testing |
| NF-005 | | | | | | | |

### Integration Risks

| ID | Risk Description | Integration Point | Likelihood | Impact | Score | Level | Mitigation Strategy |
|----|-----------------|-------------------|:----------:|:------:|:-----:|:-----:|---------------------|
| IR-001 | Payment gateway timeout | Payment API | 3 | 4 | 12 | High | Timeout handling + retry testing |
| IR-002 | Email delivery failure | Email service | 2 | 3 | 6 | Medium | Delivery verification + fallback |
| IR-003 | Third-party API changes | External APIs | 3 | 4 | 12 | High | Contract testing + version monitoring |
| IR-004 | | | | | | | |

---

## Risk Summary by Level

| Risk Level | Count | Test Priority | Coverage Target |
|------------|:-----:|:-------------:|:---------------:|
| Critical (20-25) | 0 | P0 - Mandatory | 100% |
| High (13-19) | 3 | P1 - Essential | 100% |
| Medium (6-12) | 5 | P2 - Important | 80%+ |
| Low (1-5) | 0 | P3 - Nice to have | 50%+ |

---

## Test Prioritization Based on Risk

### Suite Tier Mapping

| Risk Level | Smoke | Sanity | Regression | Full |
|------------|:-----:|:------:|:----------:|:----:|
| Critical | Yes | Yes | Yes | Yes |
| High | Yes | Yes | Yes | Yes |
| Medium | - | Sample | Yes | Yes |
| Low | - | - | Sample | Yes |

### Testing Effort Allocation

| Risk Level | % of Effort | Techniques |
|------------|:-----------:|------------|
| Critical | 40% | All techniques, multiple rounds |
| High | 30% | Comprehensive functional + NFR |
| Medium | 20% | Standard coverage |
| Low | 10% | Basic verification |

---

## Risk Monitoring

### Risk Status Tracking

| Risk ID | Initial Score | Current Score | Trend | Status | Notes |
|---------|:-------------:|:-------------:|:-----:|--------|-------|
| FR-001 | 15 | 12 | ↓ | Mitigated | Additional tests added |
| FR-002 | 8 | 8 | → | Open | In progress |
| NF-001 | 12 | 15 | ↑ | Escalated | Performance degradation found |

### New Risks Identified During Testing

| ID | Risk | Source | Likelihood | Impact | Score | Action |
|----|------|--------|:----------:|:------:|:-----:|--------|
| | | | | | | |

---

## Residual Risks (Post-Testing)

| Risk ID | Residual Score | Justification | Accepted By |
|---------|:--------------:|---------------|-------------|
| | | | |

---

## Revision History

| Version | Date | Author | Changes |
|:-------:|------|--------|---------|
| 0.1 | {{date}} | {{owner}} | Initial assessment |
