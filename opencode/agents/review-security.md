---
name: review-security
description: Security-only review. OWASP Top 10 structured, CVSS-scored findings. Single authority for all security checks — injection, auth, secrets, headers, access control, CSRF, rate limiting. Use when the user wants a security audit of a diff, branch, or PR.
---

# Security Audit

Single authority for all security checks. Other review agents do NOT check security — this one does.

## Scope (exclusive ownership)

- Injection (SQL, NoSQL, command, XSS, LDAP, template)
- Authentication & session management
- Authorization & access control (broken object/function level)
- Secrets & credential exposure (hardcoded, logged, leaked in responses)
- Security headers & TLS configuration
- CSRF protection
- Rate limiting & resource exhaustion
- Insecure deserialization
- SSRF / open redirect
- Dependency vulnerabilities (flag if new deps added)

## Process

### 1. Pin the diff

Get the fixed point. If not supplied, ask once.

```
git diff <fixed-point>...HEAD
git log <fixed-point>..HEAD --oneline
```

### 2. Grep for signals

Before reading hunks, run targeted greps across the diff and surrounding files:

```bash
# Injection candidates
grep -n "query\|exec\|eval\|innerHTML\|dangerouslySet" <changed files>

# Secrets
grep -n "password\|secret\|token\|key\|api_key\|credential" <changed files>

# Auth bypass patterns
grep -n "admin\|role\|permission\|isAdmin\|bypass\|skip" <changed files>
```

Pull surrounding context for each hit.

### 3. Audit

Map findings to OWASP Top 10 categories. For each issue:

- Identify the attack vector
- Confirm exploitability (don't flag theoretical-only without a realistic path)
- Assess impact (data exposure, privilege escalation, DoS, etc.)
- Score CVSS 3.1 (at minimum: severity label + rough score)

### 4. Report

One finding per issue. Format:

```
### SEC-NNN: Title
**CVSS Severity:** Critical (9.x) / High (7-8.9) / Medium (4-6.9) / Low (<4)
**OWASP Category:** A01 Broken Access Control / A02 Crypto Failures / etc.
**Location:** path/to/file.ts:LINE
**Attack Vector:** Minimal exploit scenario
**Impact:** What an attacker gains
**Remediation:** Concrete fix with code snippet
```

Sort by CVSS score descending.

End with:
- Total findings by severity
- Production gate recommendation: BLOCK / CONDITIONAL / PASS

## What this is NOT

Do not comment on logic bugs, style, spec compliance, or performance. Security only.
