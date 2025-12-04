# CI/CD Pipeline Standards

> Standard CI/CD configurations for all OmniPlatform repositories.

## Overview

All OmniPlatform projects should implement consistent security scanning in their CI/CD pipelines. This document defines the standard tools, configurations, and workflows.

## Security Scanning Strategy

### Two-Tier Approach

| Tier | Tools | When | Cost |
|------|-------|------|------|
| **Automated CI** | Semgrep, Gitleaks, Trivy | Every PR/push | Free |
| **Deep Analysis** | Claude ASVS Agent | Local, pre-release | Claude Max (local) or API |

**Rationale**: Free SAST tools catch common vulnerabilities automatically. Claude-powered ASVS analysis provides deeper, context-aware security review but requires either local execution (Claude Max) or API access.

---

## Free SAST Tools

### 1. Semgrep (Code Analysis)

**Purpose**: Pattern-based security scanning for OWASP Top 10 and common vulnerabilities.

| Aspect | Details |
|--------|---------|
| **Cost** | Free |
| **Languages** | JS/TS, Python, Go, Java, PHP, Ruby, C#, and more |
| **Speed** | Fast (~30 seconds for typical project) |
| **False Positives** | Low |

**Rule Packs to Use**:
- `p/owasp-top-ten` - OWASP Top 10 vulnerabilities
- `p/security-audit` - General security issues
- `p/secrets` - Hardcoded secrets detection
- `p/typescript` - TypeScript-specific (for OmniUI, OmniDS)
- `p/csharp` - C#-specific (for OmniCore, backend services)

**Documentation**: https://semgrep.dev/docs/

---

### 2. Gitleaks (Secrets Detection)

**Purpose**: Detect hardcoded secrets, API keys, passwords in code and git history.

| Aspect | Details |
|--------|---------|
| **Cost** | Free |
| **Scans** | Current code + git history |
| **Speed** | Very fast |
| **False Positives** | Very low |

**What It Catches**:
- API keys (AWS, Azure, GCP, Stripe, etc.)
- Private keys and certificates
- Database connection strings
- OAuth tokens
- Passwords in code

**Documentation**: https://github.com/gitleaks/gitleaks

---

### 3. Trivy (Vulnerability Scanner)

**Purpose**: Comprehensive vulnerability scanning for dependencies, containers, and IaC.

| Aspect | Details |
|--------|---------|
| **Cost** | Free |
| **Scans** | Dependencies, Docker images, Terraform, Kubernetes |
| **Database** | Uses multiple CVE databases |
| **Speed** | Fast |

**Scan Types**:
- `fs` - Filesystem (package.json, requirements.txt, etc.)
- `image` - Docker/container images
- `config` - IaC misconfigurations

**Documentation**: https://trivy.dev/

---

### 4. GitHub CodeQL (Optional)

**Purpose**: Deep semantic code analysis.

| Aspect | Details |
|--------|---------|
| **Cost** | Free for public repos, GitHub Advanced Security for private |
| **Languages** | JS/TS, Python, Go, Java, C/C++, C#, Ruby |
| **Speed** | Slower (minutes) |
| **Depth** | Deep dataflow analysis |

**When to Use**: For critical repositories where deeper analysis justifies the slower build times.

**Documentation**: https://codeql.github.com/

---

### 5. OSV-Scanner (Dependency Vulnerabilities)

**Purpose**: Check dependencies against Google's Open Source Vulnerabilities database.

| Aspect | Details |
|--------|---------|
| **Cost** | Free |
| **Focus** | Known CVEs in dependencies |
| **Speed** | Very fast |

**Documentation**: https://google.github.io/osv-scanner/

---

## Standard Workflow

### Recommended Configuration

Every OmniPlatform repository should have this workflow at `.github/workflows/security.yml`:

```yaml
name: Security Scan

on:
  pull_request:
  push:
    branches: [main, master, develop]

jobs:
  security-scan:
    name: Security Analysis
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for gitleaks

      # 1. Secrets Detection (CRITICAL - runs first)
      - name: Gitleaks - Secrets Scan
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # 2. Code Vulnerabilities (OWASP patterns)
      - name: Semgrep - Code Analysis
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/security-audit
            p/secrets

      # 3. Dependency Vulnerabilities
      - name: Trivy - Vulnerability Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
          format: 'sarif'
          output: 'trivy-results.sarif'

      # 4. Upload results to GitHub Security tab
      - name: Upload Trivy Results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```

### Language-Specific Additions

#### For TypeScript/JavaScript Projects (OmniUI, OmniDS)

Add to Semgrep config:
```yaml
config: >-
  p/owasp-top-ten
  p/security-audit
  p/secrets
  p/typescript
  p/react        # If using React
  p/nodejs
```

#### For C#/.NET Projects (OmniCore, OmniID)

Add to Semgrep config:
```yaml
config: >-
  p/owasp-top-ten
  p/security-audit
  p/secrets
  p/csharp
```

#### For Projects with Docker

Add Trivy image scan:
```yaml
- name: Trivy - Container Scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'your-image:tag'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

---

## Branch Protection

After adding the security workflow, configure branch protection:

1. Go to **Settings → Branches → Add rule**
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
4. Select required checks:
   - `Security Analysis` (or your job name)

This prevents merging PRs that fail security scans.

---

## ASVS Deep Analysis (Local)

For deeper security review, use the ASVS agent locally with Claude Max:

```bash
# In your project directory
claude "/agent-asvs"
```

**When to Use**:
- Before major releases
- After significant security-relevant changes
- During security reviews
- When investigating potential vulnerabilities

**Agent Location**: `OmniAgents/security/asvs-auditor.md`

The ASVS agent provides:
- OWASP ASVS 4.0 compliance checking
- Specific requirement mapping (V2.1.1, V5.3.4, etc.)
- Code evidence with file paths and line numbers
- Remediation guidance

---

## CI with Claude API (Optional)

If you have Anthropic API access, you can run ASVS scans in CI:

**Requirements**:
- Anthropic API key (separate from Claude Max)
- Add `ANTHROPIC_API_KEY` to repository secrets

**Workflow**: See `.github/workflows/asvs-security-gate.yml` in this repository.

**CI Agent**: Use `OmniAgents/security/asvs-auditor-ci.md` which outputs JSON for pipeline consumption.

---

## Quick Setup Checklist

For each OmniPlatform repository:

- [ ] Copy `.github/workflows/security.yml` to repository
- [ ] Adjust Semgrep rules for language/framework
- [ ] Enable branch protection requiring security checks
- [ ] Test by creating a PR with an intentional issue
- [ ] Document any project-specific security considerations

---

## Severity and Response

| Finding Severity | CI Behavior | Response Time |
|-----------------|-------------|---------------|
| **Critical** | Block merge | Fix immediately |
| **High** | Block merge | Fix before merge |
| **Medium** | Warning | Fix within sprint |
| **Low** | Info only | Backlog |

---

## Tool Comparison Summary

| Tool | What It Finds | Speed | When to Use |
|------|--------------|-------|-------------|
| **Gitleaks** | Secrets in code/history | ⚡ Fast | Always (first check) |
| **Semgrep** | Code vulnerabilities, patterns | ⚡ Fast | Always |
| **Trivy** | Dependency CVEs, container issues | ⚡ Fast | Always |
| **CodeQL** | Deep dataflow bugs | 🐢 Slow | Critical repos |
| **ASVS Agent** | OWASP compliance, context-aware | 🐢 Slow | Pre-release, reviews |

---

## References

- [OWASP ASVS 4.0](https://github.com/OWASP/ASVS)
- [Semgrep Rules](https://semgrep.dev/r)
- [Trivy Documentation](https://trivy.dev/)
- [Gitleaks](https://github.com/gitleaks/gitleaks)
- [GitHub Security Features](https://docs.github.com/en/code-security)

---

*Last updated: December 2025*
