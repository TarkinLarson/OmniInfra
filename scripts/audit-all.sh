#!/bin/bash
#
# Audit Security Configuration Across All OmniPlatform Repos
# Checks which projects have security scanning configured
#
# Usage: ./audit-all.sh [repos-directory]
#

set -e

REPOS_DIR="${1:-$(dirname "$(dirname "$(dirname "$0")")")}"

echo "Auditing OmniPlatform repositories in: $REPOS_DIR"
echo "==========================================="
echo ""

# Known Omni projects
OMNI_PROJECTS=(
    "Omni"
    "OmniAgents"
    "OmniDS"
    "OmniUI"
    "OmniID"
    "OmniInfra"
    "project-template"
)

printf "%-20s %-15s %-15s %-10s\n" "PROJECT" "SECURITY.YML" "TYPE" "PROTECTED"
printf "%-20s %-15s %-15s %-10s\n" "-------" "------------" "----" "---------"

for project in "${OMNI_PROJECTS[@]}"; do
    PROJECT_PATH="$REPOS_DIR/$project"

    if [ ! -d "$PROJECT_PATH" ]; then
        printf "%-20s %-15s %-15s %-10s\n" "$project" "NOT FOUND" "-" "-"
        continue
    fi

    WORKFLOW_PATH="$PROJECT_PATH/.github/workflows/security.yml"

    if [ -f "$WORKFLOW_PATH" ]; then
        HAS_WORKFLOW="✅ Yes"

        # Detect type from workflow content
        if grep -q "typescript" "$WORKFLOW_PATH" 2>/dev/null; then
            WORKFLOW_TYPE="typescript"
        elif grep -q "dotnet\|csharp" "$WORKFLOW_PATH" 2>/dev/null; then
            WORKFLOW_TYPE="dotnet"
        else
            WORKFLOW_TYPE="generic"
        fi
    else
        HAS_WORKFLOW="❌ No"
        WORKFLOW_TYPE="-"
    fi

    # Check if it's a git repo and has remote
    if [ -d "$PROJECT_PATH/.git" ]; then
        # Could add gh api check for branch protection here
        PROTECTED="?"
    else
        PROTECTED="-"
    fi

    printf "%-20s %-15s %-15s %-10s\n" "$project" "$HAS_WORKFLOW" "$WORKFLOW_TYPE" "$PROTECTED"
done

echo ""
echo "==========================================="
echo ""
echo "Legend:"
echo "  ✅ Yes     - Security workflow configured"
echo "  ❌ No      - Missing security workflow (run setup-security.sh)"
echo "  NOT FOUND  - Project directory doesn't exist"
echo "  ?          - Branch protection unknown (check GitHub settings)"
echo ""
echo "To add security scanning to a project:"
echo "  cd <project>"
echo "  $REPOS_DIR/OmniInfra/scripts/setup-security.sh"
echo ""
