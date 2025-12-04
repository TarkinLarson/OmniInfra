# OmniInfra

Infrastructure, CI/CD, and DevOps configurations for the OmniPlatform suite.

## Overview

This repository contains:
- **CI/CD workflow templates** - Reusable GitHub Actions for all projects
- **Security scanning configurations** - SAST tools and policies
- **Infrastructure as Code** - Terraform/Bicep templates (future)
- **Deployment scripts** - Automation for setting up new projects

## Quick Start

### Add Security Scanning to a Project

```bash
# Run from your project directory
../OmniInfra/scripts/setup-security.sh

# Or specify project type
../OmniInfra/scripts/setup-security.sh --type typescript
../OmniInfra/scripts/setup-security.sh --type dotnet
```

### Manual Setup

Copy the appropriate workflow to your project:

```bash
# For TypeScript/React projects (OmniUI, OmniDS)
cp OmniInfra/workflows/security-typescript.yml YourProject/.github/workflows/security.yml

# For .NET/C# projects (OmniCore, OmniID)
cp OmniInfra/workflows/security-dotnet.yml YourProject/.github/workflows/security.yml

# For generic projects
cp OmniInfra/workflows/security.yml YourProject/.github/workflows/security.yml
```

## Contents

### Workflows

#### Security Scanning
| File | Purpose | Use For |
|------|---------|---------|
| `workflows/security.yml` | Base security scanning | All projects |
| `workflows/security-typescript.yml` | TypeScript/React scanning | OmniUI, OmniDS |
| `workflows/security-dotnet.yml` | .NET/C# scanning | OmniCore, OmniID |
| `workflows/asvs-security-gate.yml` | Claude API + ASVS scanning | Requires Anthropic API key |

#### CI (Lint, Build, Test)
| File | Purpose | Use For |
|------|---------|---------|
| `workflows/ci-node.yml` | Node.js CI (lint, build, test) | General Node/TypeScript |
| `workflows/ci-css-library.yml` | CSS library CI (CSS lint, build) | OmniUI, OmniDS |
| `workflows/ci-dotnet.yml` | .NET CI (build, test) | OmniCore, OmniID |

#### Deployment
| File | Purpose | Use For |
|------|---------|---------|
| `workflows/pages-node.yml` | GitHub Pages deployment | Documentation sites |

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/setup-security.sh` | Add security workflow to a project |
| `scripts/audit-all.sh` | Run security audit across all repos |

### Documentation

| File | Purpose |
|------|---------|
| `CICD.md` | Complete CI/CD standards and tool documentation |
| `SECURITY-TOOLS.md` | Detailed guide to each security tool |

### Infrastructure (Future)

```
terraform/           # Terraform modules for cloud infrastructure
bicep/              # Azure Bicep templates
```

## Security Scanning Stack

All OmniPlatform projects use this security toolchain:

| Tool | Purpose | Cost |
|------|---------|------|
| **Gitleaks** | Secrets detection in code and git history | Free |
| **Semgrep** | Pattern-based code analysis (OWASP Top 10) | Free |
| **Trivy** | Dependency and container vulnerabilities | Free |
| **ASVS Agent** | Deep OWASP ASVS compliance review | Claude Max (local) |

### CI Pipeline Flow

```
┌─────────────────────────────────────────────────────────────┐
│  PR / Push to main                                          │
├─────────────────────────────────────────────────────────────┤
│  1. Gitleaks     → Scan for secrets (CRITICAL - runs first) │
│  2. Semgrep      → Code vulnerabilities (OWASP patterns)    │
│  3. Trivy        → Dependency CVEs                          │
│  4. Upload SARIF → Results to GitHub Security tab           │
├─────────────────────────────────────────────────────────────┤
│  ✅ Pass → PR can be merged                                 │
│  ❌ Fail → PR blocked until issues fixed                    │
└─────────────────────────────────────────────────────────────┘
```

### Local Deep Analysis

For pre-release security reviews, use the ASVS agent locally:

```bash
# In your project directory
claude "/agent-asvs"
```

See [OmniAgents/security/](../OmniAgents/security/) for agent definitions.

## Branch Protection

After adding security workflows, enable branch protection:

1. **Settings → Branches → Add rule**
2. Branch: `main`
3. Enable:
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
4. Select required checks: `Security Analysis`

## Related Repositories

| Repository | Purpose |
|------------|---------|
| [Omni](../Omni) | Architecture documentation |
| [OmniAgents](../OmniAgents) | AI agent definitions (including ASVS) |
| [project-template](../project-template) | New project template |

## Contributing

When adding new workflows or scripts:
1. Test in a real project first
2. Update CICD.md with any new tools
3. Update project-template if it should be included by default

---

*Last updated: December 2025*
