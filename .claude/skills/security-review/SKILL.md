---
name: security-review
description: Load after writing or reviewing code that handles user input, authentication, API endpoints, or sensitive data. Defines the OWASP-oriented security checklist, severity classification, common vulnerability catalog, and the standard finding output format.
---

# Security Review Workflow

Guidelines for conducting a security review in the main session, focused on
identifying and remediating vulnerabilities before they reach production.
Review code, configurations, and dependencies against the criteria below.

## Core Focus Areas

1. **Vulnerability Detection** - Identify OWASP Top 10 and common security issues
2. **Secrets Detection** - Find hardcoded API keys, passwords, tokens
3. **Input Validation** - Ensure all user inputs are properly sanitized
4. **Authentication/Authorization** - Verify proper access controls
5. **Dependency Security** - Check for vulnerable packages
6. **Security Best Practices** - Enforce secure coding patterns

## Mandatory Security Checklist

Verify the following before treating the change as safe:

- [ ] **No hardcoded secrets** (API keys, passwords, tokens, connection strings)
- [ ] **All user inputs validated** (type, length, format, range)
- [ ] **SQL injection prevention** (parameterized queries, ORMs)
- [ ] **XSS prevention** (sanitized HTML, escaped output, CSP headers)
- [ ] **CSRF protection enabled** (tokens, SameSite cookies)
- [ ] **Authentication/authorization verified** (proper session management, role checks)
- [ ] **Rate limiting on all endpoints** (prevent brute force, DoS)
- [ ] **Error messages don't leak sensitive data** (stack traces, internal paths)

## Security Response Protocol

When a security issue is found:

1. **CLASSIFY** - Determine severity (CRITICAL, HIGH, MEDIUM, LOW)
2. **REPORT** - Document the vulnerability clearly using the output format below
3. **FIX** - Address CRITICAL and HIGH issues before continuing
4. **ROTATE** - If secrets are exposed, rotate them immediately
5. **REVIEW** - Search the rest of the codebase for similar vulnerabilities

## Severity Classification

| Severity | Description | Action |
|----------|-------------|--------|
| CRITICAL | Data breach possible, RCE, auth bypass | Fix immediately, block merge |
| HIGH | Significant security weakness | Fix before merge |
| MEDIUM | Defense-in-depth issue | Fix in same sprint |
| LOW | Minor hardening opportunity | Track for future fix |

## Common Vulnerabilities to Check

### Injection Attacks
- SQL Injection
- NoSQL Injection
- Command Injection
- LDAP Injection
- XPath Injection

### Authentication Issues
- Weak password policies
- Missing MFA
- Session fixation
- Insecure password storage

### Data Exposure
- Sensitive data in logs
- Unencrypted data in transit
- PII exposure in URLs
- Overly permissive CORS

### Configuration
- Debug mode in production
- Default credentials
- Unnecessary services exposed
- Missing security headers

## Output Format

When reporting findings, use this format:

```
## Security Finding

**Severity**: [CRITICAL/HIGH/MEDIUM/LOW]
**Type**: [Vulnerability type]
**Location**: [File:line]

**Description**: [What the issue is]

**Impact**: [What could happen if exploited]

**Recommendation**: [How to fix it]

**Code Example**:
[Before/After code snippets]
```
