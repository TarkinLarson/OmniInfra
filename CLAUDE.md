# CLAUDE.md - OmniInfra

> Instructions for AI assistants working with this repository.

## What This Repository Is

OmniInfra contains infrastructure, CI/CD, and DevOps configurations for the entire OmniPlatform suite. It's the **operational backbone** that ensures consistent security, deployment, and infrastructure across all projects.

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Overview and quick start |
| `CICD.md` | **Complete CI/CD standards** — Tools, configurations, policies |
| `workflows/*.yml` | GitHub Actions workflow templates |
| `scripts/*.sh` | Automation scripts for project setup |

## Core Concepts

### Security Scanning Strategy

**Two-tier approach:**
1. **Automated CI** (free tools) - Runs on every PR/push
2. **Deep Analysis** (Claude ASVS) - Local, pre-release reviews

### Workflow Templates

Three variants for different project types:
- `security.yml` - Base template (generic)
- `security-typescript.yml` - TypeScript/React (OmniUI, OmniDS)
- `security-dotnet.yml` - .NET/C# (OmniCore, OmniID)

### Tool Stack

| Tool | What It Does |
|------|-------------|
| Gitleaks | Finds secrets in code and git history |
| Semgrep | Pattern-based OWASP vulnerability scanning |
| Trivy | Dependency and container CVE scanning |

## Common Tasks

### "Add security scanning to a project"
→ Use `scripts/setup-security.sh` or copy appropriate workflow from `workflows/`

### "What security tools should we use?"
→ See CICD.md for full comparison and recommendations

### "How do I run a deep security review?"
→ Use Claude locally with `/agent-asvs` (see OmniAgents repo)

### "Add a new CI/CD tool"
1. Test in a real project first
2. Add workflow variant if needed
3. Document in CICD.md
4. Update project-template if it should be default

## Related Repositories

- **Omni** - Architecture documentation (references this repo)
- **OmniAgents** - AI agents including ASVS auditor
- **project-template** - New project template (includes security workflow)

## Rules

1. **Test before committing** - All workflow changes should be tested in a real project
2. **Document everything** - Update CICD.md when adding tools
3. **Keep it simple** - Prefer free, well-maintained tools
4. **Security first** - Gitleaks always runs first in pipelines
