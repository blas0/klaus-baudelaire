#!/usr/bin/env bash
# setup-github-actions.sh
# Enable/disable GitHub Actions workflows for Klaus System
# Part of Phase 1, Week 4: CI/CD Integration (OPTIONAL)

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Templates are in klaus-baudelaire/ (same directory as this script)
TEMPLATES_DIR="$SCRIPT_DIR/.github-workflows-templates"
# Workflows go in project root (klaus-baudelaire/ or user's repo)
WORKFLOWS_DIR="$PROJECT_ROOT/.github/workflows"
CONFIG_FILE="$HOME/.claude/klaus-delegation.conf"

# Color codes
COLOR_GREEN="\033[0;32m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;34m"
COLOR_RESET="\033[0m"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
    echo ""
}

print_success() {
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} $1"
}

print_error() {
    echo -e "${COLOR_RED}✗${COLOR_RESET} $1"
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠${COLOR_RESET} $1"
}

print_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"
}

# ============================================================================
# Validation Functions
# ============================================================================

validate_git_repo() {
    if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
        print_error "Not a git repository. GitHub Actions requires git."
        echo "Initialize git first: cd $PROJECT_ROOT && git init"
        return 1
    fi
    print_success "Git repository detected"
    return 0
}

validate_templates_exist() {
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        print_error "Workflow templates directory not found: $TEMPLATES_DIR"
        echo "Expected location: $TEMPLATES_DIR"
        return 1
    fi

    local template_count
    template_count=$(find "$TEMPLATES_DIR" -name "*.yml" -type f | wc -l | tr -d ' ')

    if [[ $template_count -eq 0 ]]; then
        print_error "No workflow templates found in $TEMPLATES_DIR"
        return 1
    fi

    print_success "Found $template_count workflow template(s)"
    return 0
}

check_workflows_enabled() {
    if [[ -d "$WORKFLOWS_DIR" ]] && [[ -n "$(ls -A "$WORKFLOWS_DIR" 2>/dev/null)" ]]; then
        return 0  # Workflows enabled
    fi
    return 1  # Workflows disabled
}

# ============================================================================
# Workflow Management
# ============================================================================

enable_workflows() {
    print_header "Enabling GitHub Actions Workflows"

    # Create .github/workflows directory
    mkdir -p "$WORKFLOWS_DIR"
    print_success "Created workflows directory: $WORKFLOWS_DIR"

    # Copy templates to workflows
    local copied_count=0
    for template_file in "$TEMPLATES_DIR"/*.yml; do
        if [[ -f "$template_file" ]]; then
            local filename
            filename=$(basename "$template_file")
            cp "$template_file" "$WORKFLOWS_DIR/$filename"
            print_success "Enabled: $filename"
            copied_count=$((copied_count + 1))
        fi
    done

    if [[ $copied_count -eq 0 ]]; then
        print_error "No workflows were copied"
        return 1
    fi

    # Update config flag
    update_config_flag "ON"

    echo ""
    print_success "GitHub Actions enabled ($copied_count workflow(s))"
    echo ""
    print_info "Next steps:"
    echo "  1. Review workflows in $WORKFLOWS_DIR"
    echo "  2. Commit workflows: git add .github/workflows && git commit -m 'Add GitHub Actions workflows'"
    echo "  3. Push to GitHub: git push origin main"
    echo "  4. Configure secrets in repository settings (if needed)"
    echo ""

    return 0
}

disable_workflows() {
    print_header "Disabling GitHub Actions Workflows"

    if [[ ! -d "$WORKFLOWS_DIR" ]]; then
        print_warning "Workflows directory does not exist, nothing to disable"
        return 0
    fi

    # Move workflows back to templates (backup)
    local moved_count=0
    for workflow_file in "$WORKFLOWS_DIR"/*.yml; do
        if [[ -f "$workflow_file" ]]; then
            local filename
            filename=$(basename "$workflow_file")
            # Don't overwrite templates, just remove from workflows
            rm "$workflow_file"
            print_success "Disabled: $filename"
            moved_count=$((moved_count + 1))
        fi
    done

    # Remove empty workflows directory
    if [[ -d "$WORKFLOWS_DIR" ]] && [[ -z "$(ls -A "$WORKFLOWS_DIR" 2>/dev/null)" ]]; then
        rmdir "$WORKFLOWS_DIR"
        print_success "Removed empty workflows directory"
    fi

    # Update config flag
    update_config_flag "OFF"

    echo ""
    print_success "GitHub Actions disabled ($moved_count workflow(s) removed)"
    echo ""
    print_info "Workflow templates preserved in $TEMPLATES_DIR"
    echo "Run this script again to re-enable workflows"
    echo ""

    return 0
}

update_config_flag() {
    local new_value="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_warning "Config file not found: $CONFIG_FILE"
        return 1
    fi

    # Update ENABLE_GITHUB_ACTIONS flag
    if grep -q "^ENABLE_GITHUB_ACTIONS=" "$CONFIG_FILE"; then
        # macOS-compatible sed with backup
        sed -i.bak "s|^ENABLE_GITHUB_ACTIONS=.*|ENABLE_GITHUB_ACTIONS=\"$new_value\"|g" "$CONFIG_FILE"
        rm -f "${CONFIG_FILE}.bak"
        print_success "Updated config: ENABLE_GITHUB_ACTIONS=$new_value"
    else
        print_warning "ENABLE_GITHUB_ACTIONS flag not found in config"
    fi

    return 0
}

# ============================================================================
# Status Display
# ============================================================================

show_status() {
    print_header "GitHub Actions Status"

    if check_workflows_enabled; then
        echo -e "${COLOR_GREEN}Status: ENABLED${COLOR_RESET}"
        echo ""
        echo "Active workflows:"
        for workflow_file in "$WORKFLOWS_DIR"/*.yml; do
            if [[ -f "$workflow_file" ]]; then
                echo "  • $(basename "$workflow_file")"
            fi
        done
    else
        echo -e "${COLOR_YELLOW}Status: DISABLED${COLOR_RESET}"
        echo ""
        echo "Available templates:"
        for template_file in "$TEMPLATES_DIR"/*.yml; do
            if [[ -f "$template_file" ]]; then
                echo "  • $(basename "$template_file")"
            fi
        done
    fi

    echo ""
    print_info "To change status, run: $0 enable|disable"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    local command="${1:-status}"

    print_header "Klaus GitHub Actions Setup"

    # Validate prerequisites
    if ! validate_git_repo; then
        exit 1
    fi

    if ! validate_templates_exist; then
        print_error "Week 4 not yet implemented - workflow templates not available"
        exit 1
    fi

    # Execute command
    case "$command" in
        enable)
            if check_workflows_enabled; then
                print_warning "GitHub Actions already enabled"
                show_status
                exit 0
            fi
            enable_workflows
            ;;
        disable)
            if ! check_workflows_enabled; then
                print_warning "GitHub Actions already disabled"
                show_status
                exit 0
            fi
            disable_workflows
            ;;
        status)
            show_status
            ;;
        *)
            print_error "Invalid command: $command"
            echo ""
            echo "Usage: $0 {enable|disable|status}"
            echo ""
            echo "Commands:"
            echo "  enable   - Enable GitHub Actions workflows"
            echo "  disable  - Disable GitHub Actions workflows"
            echo "  status   - Show current status"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
