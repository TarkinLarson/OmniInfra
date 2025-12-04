#!/bin/bash
#
# Setup Security Scanning for OmniPlatform Projects
# Copies the appropriate security workflow to a project
#
# Usage:
#   ./setup-security.sh                    # Auto-detect project type
#   ./setup-security.sh --type typescript  # Force TypeScript workflow
#   ./setup-security.sh --type dotnet      # Force .NET workflow
#   ./setup-security.sh --type generic     # Use base workflow
#
# Run from target project directory or specify path:
#   ./setup-security.sh --path ../OmniUI
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_ROOT="$(dirname "$SCRIPT_DIR")"
WORKFLOWS_DIR="$INFRA_ROOT/workflows"

# Defaults
PROJECT_TYPE=""
PROJECT_PATH="."

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        --path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--type typescript|dotnet|generic] [--path /path/to/project]"
            echo ""
            echo "Options:"
            echo "  --type     Force project type (typescript, dotnet, generic)"
            echo "  --path     Path to target project (default: current directory)"
            echo ""
            echo "If --type is not specified, the script will auto-detect based on:"
            echo "  - package.json with React/TypeScript → typescript"
            echo "  - *.csproj or *.sln files → dotnet"
            echo "  - Otherwise → generic"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Resolve project path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

echo "Setting up security scanning for: $PROJECT_NAME"
echo "Project path: $PROJECT_PATH"
echo "==========================================="

# Auto-detect project type if not specified
if [ -z "$PROJECT_TYPE" ]; then
    echo ""
    echo "Auto-detecting project type..."

    if [ -f "$PROJECT_PATH/package.json" ]; then
        # Check for TypeScript/React indicators
        if grep -qE '"typescript"|"react"|"@types"' "$PROJECT_PATH/package.json" 2>/dev/null; then
            PROJECT_TYPE="typescript"
            echo "  Detected: TypeScript/React project"
        else
            PROJECT_TYPE="generic"
            echo "  Detected: Node.js project (using generic workflow)"
        fi
    elif ls "$PROJECT_PATH"/*.csproj 2>/dev/null || ls "$PROJECT_PATH"/*.sln 2>/dev/null; then
        PROJECT_TYPE="dotnet"
        echo "  Detected: .NET/C# project"
    elif [ -f "$PROJECT_PATH/requirements.txt" ] || [ -f "$PROJECT_PATH/pyproject.toml" ]; then
        PROJECT_TYPE="generic"
        echo "  Detected: Python project (using generic workflow)"
    else
        PROJECT_TYPE="generic"
        echo "  Could not detect type, using generic workflow"
    fi
fi

# Select workflow file
case $PROJECT_TYPE in
    typescript)
        WORKFLOW_FILE="security-typescript.yml"
        ;;
    dotnet)
        WORKFLOW_FILE="security-dotnet.yml"
        ;;
    *)
        WORKFLOW_FILE="security.yml"
        ;;
esac

SOURCE_WORKFLOW="$WORKFLOWS_DIR/$WORKFLOW_FILE"
TARGET_DIR="$PROJECT_PATH/.github/workflows"
TARGET_WORKFLOW="$TARGET_DIR/security.yml"

# Check source exists
if [ ! -f "$SOURCE_WORKFLOW" ]; then
    echo "Error: Workflow file not found: $SOURCE_WORKFLOW"
    exit 1
fi

# Create target directory
echo ""
echo "Creating workflow directory..."
mkdir -p "$TARGET_DIR"

# Check if workflow already exists
if [ -f "$TARGET_WORKFLOW" ]; then
    echo ""
    echo "Warning: $TARGET_WORKFLOW already exists!"
    read -p "Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Copy workflow
echo "Copying workflow: $WORKFLOW_FILE → security.yml"
cp "$SOURCE_WORKFLOW" "$TARGET_WORKFLOW"

echo ""
echo "==========================================="
echo "✅ Security scanning configured!"
echo ""
echo "Workflow: $TARGET_WORKFLOW"
echo "Type: $PROJECT_TYPE"
echo ""
echo "Next steps:"
echo "  1. Commit the workflow:"
echo "     cd $PROJECT_PATH"
echo "     git add .github/workflows/security.yml"
echo "     git commit -m 'Add security scanning workflow'"
echo ""
echo "  2. Enable branch protection (optional but recommended):"
echo "     Go to: Settings → Branches → Add rule"
echo "     - Branch name: main"
echo "     - ✓ Require status checks to pass"
echo "     - Select: 'Security Analysis'"
echo ""
echo "  3. Test by creating a PR with changes"
echo ""
echo "For deep security analysis, run locally:"
echo "  claude \"/agent-asvs\""
echo ""
