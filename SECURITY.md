# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| main    | ✅ Current |

## Reporting a Vulnerability

OmniInfra contains CI/CD workflows, infrastructure templates, and deployment scripts. Security is critical as these run with elevated privileges.

### What to Report

- Workflow vulnerabilities (command injection, secret exposure)
- Insecure defaults in templates
- Bicep/Terraform templates with security misconfigurations
- Scripts that could leak credentials
- Supply chain risks (compromised actions, dependencies)

### How to Report

1. **Do not** open a public issue for security vulnerabilities
2. Email security concerns to the repository owner
3. Include:
   - Which file is affected
   - Description of the vulnerability
   - Steps to reproduce
   - Suggested fix (if any)

### Response Timeline

- Acknowledgment: 24 hours
- Initial assessment: 48 hours
- Resolution: Based on severity (Critical: 3 days, High: 7 days)

## Security Scanning

This repository provides security scanning templates for other projects:

- **Gitleaks** — Secrets detection
- **Semgrep** — OWASP pattern matching
- **Trivy** — Dependency and container scanning

## Workflow Security Guidelines

When creating or modifying workflows:

1. **Pin action versions** — Use SHA hashes, not tags (`actions/checkout@abc123` not `@v4`)
2. **Minimal permissions** — Only request permissions actually needed
3. **No secrets in logs** — Use `::add-mask::` for dynamic secrets
4. **Validate inputs** — Sanitize workflow inputs to prevent injection
5. **Review third-party actions** — Check source before using

## Infrastructure Template Guidelines

When creating Bicep/Terraform templates:

1. **No hardcoded credentials** — Use Key Vault references
2. **Enable encryption** — At rest and in transit
3. **Use managed identities** — Avoid service principal secrets
4. **Least privilege** — Minimal RBAC assignments
5. **Enable logging** — Diagnostic settings on all resources
