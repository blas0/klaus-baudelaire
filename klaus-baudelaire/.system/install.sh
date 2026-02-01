#!/bin/bash
# Klaus Baudelaire - Installation Script
# Supports: clone-anywhere, backup, merge, append
# Version: 2.0.0

set -e

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KLAUS_SOURCE="$(dirname "$SCRIPT_DIR")"  # klaus-baudelaire directory
TARGET_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-backups"
MODE="append"  # append | standalone | plugin
DRY_RUN=false
NO_BACKUP=false
VERBOSE=false

# Colors (if terminal supports it)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Helper Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log_info()    { echo -e "${BLUE}[*]${NC} $1"; }
log_success() { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[!!!]${NC} $1"; }
log_verbose() { [[ "$VERBOSE" == true ]] && echo -e "${BLUE}    ${NC} $1" || true; }

show_help() {
    cat << EOF
Klaus Baudelaire Installation Script v${VERSION}

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    --target=PATH     Installation target (default: ~/.claude)
    --mode=MODE       Installation mode:
                        append     - Add to existing ~/.claude (default)
                        standalone - Fresh install (fails if target exists)
                        plugin     - Plugin mode (uses CLAUDE_PLUGIN_ROOT)
    --no-backup       Skip backup of existing files
    --dry-run         Show what would be done without making changes
    --verbose         Show detailed output
    --help            Show this help message

EXAMPLES:
    # Standard installation (recommended)
    ./install.sh

    # Install to custom location
    ./install.sh --target=/path/to/claude

    # Fresh install (no existing ~/.claude)
    ./install.sh --mode=standalone

    # Preview installation without changes
    ./install.sh --dry-run --verbose

NOTES:
    - Clone the repository anywhere: git clone https://github.com/blas0/klaus-baudelaire
    - Run install.sh from the cloned directory
    - Your existing ~/.claude files are automatically backed up
    - settings.json hooks are MERGED (not replaced)
    - Your CLAUDE.md is preserved (not overwritten)

EOF
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Parse Arguments
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target=*)
                TARGET_DIR="${1#*=}"
                shift
                ;;
            --mode=*)
                MODE="${1#*=}"
                if [[ ! "$MODE" =~ ^(append|standalone|plugin)$ ]]; then
                    log_error "Invalid mode: $MODE (use: append, standalone, plugin)"
                    exit 1
                fi
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Validation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

validate_source() {
    log_info "Validating Klaus source directory..."

    local required_dirs=("hooks" "agents" "commands" "config")
    local required_files=("hooks/klaus-delegation.sh" ".claude-plugin/plugin.json")

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$KLAUS_SOURCE/$dir" ]]; then
            log_error "Missing required directory: $KLAUS_SOURCE/$dir"
            log_error "Are you running this from the klaus-baudelaire repository?"
            exit 1
        fi
    done

    for file in "${required_files[@]}"; do
        if [[ ! -f "$KLAUS_SOURCE/$file" ]]; then
            log_error "Missing required file: $KLAUS_SOURCE/$file"
            exit 1
        fi
    done

    log_success "Source validation passed"
}

validate_mode() {
    if [[ "$MODE" == "standalone" && -d "$TARGET_DIR" ]]; then
        log_error "Standalone mode requires empty target, but $TARGET_DIR exists"
        log_error "Use --mode=append to merge with existing installation"
        log_error "Or remove $TARGET_DIR first"
        exit 1
    fi

    if [[ "$MODE" == "plugin" ]]; then
        if [[ -n "$CLAUDE_PLUGIN_ROOT" ]]; then
            TARGET_DIR="$CLAUDE_PLUGIN_ROOT"
            log_info "Plugin mode: using CLAUDE_PLUGIN_ROOT=$TARGET_DIR"
        else
            TARGET_DIR="$HOME/.local/share/claude/plugins/klaus-baudelaire"
            log_info "Plugin mode: using default plugin path"
        fi
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Backup Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

create_backup() {
    if [[ "$NO_BACKUP" == true ]]; then
        log_warn "Skipping backup (--no-backup)"
        return 0
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        log_info "No existing installation to backup"
        return 0
    fi

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/claude-backup-$timestamp"

    log_info "Creating backup of $TARGET_DIR..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would backup to: $backup_path"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"
    cp -rp "$TARGET_DIR" "$backup_path"

    log_success "Backup created: $backup_path"

    # Cleanup old backups (keep last 5)
    local backup_count=$(ls -1d "$BACKUP_DIR"/claude-backup-* 2>/dev/null | wc -l)
    if [[ $backup_count -gt 5 ]]; then
        log_info "Cleaning old backups (keeping last 5)..."
        ls -1dt "$BACKUP_DIR"/claude-backup-* | tail -n +6 | xargs rm -rf
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Installation Functions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

install_directory() {
    local src_dir="$1"
    local dst_dir="$2"
    local dir_name="$3"

    if [[ ! -d "$src_dir" ]]; then
        log_verbose "Skipping $dir_name (not found in source)"
        return 0
    fi

    log_info "Installing $dir_name..."

    if [[ "$DRY_RUN" == true ]]; then
        local file_count=$(find "$src_dir" -type f | wc -l)
        log_info "[DRY-RUN] Would copy $file_count files to $dst_dir"
        return 0
    fi

    mkdir -p "$dst_dir"

    # Copy files, preserving existing if MODE=append
    for src_file in "$src_dir"/*; do
        [[ -e "$src_file" ]] || continue

        local filename=$(basename "$src_file")
        local dst_file="$dst_dir/$filename"

        if [[ -f "$dst_file" && "$MODE" == "append" ]]; then
            log_verbose "  Preserving existing: $filename"
            # For append mode, only copy if source is newer or file doesn't exist
            if [[ "$src_file" -nt "$dst_file" ]]; then
                log_verbose "  Updating (newer version): $filename"
                cp -p "$src_file" "$dst_file"
            fi
        else
            log_verbose "  Installing: $filename"
            cp -rp "$src_file" "$dst_file"
        fi
    done

    log_success "Installed $dir_name"
}

install_config() {
    local src_dir="$KLAUS_SOURCE/config"
    local dst_dir="$TARGET_DIR/config"

    log_info "Installing configuration files..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would install config files"
        return 0
    fi

    mkdir -p "$dst_dir"

    # Install klaus-delegation.conf (to target root, not config/)
    if [[ -f "$src_dir/klaus-delegation.conf" ]]; then
        local dst_conf="$TARGET_DIR/config/klaus-delegation.conf"
        if [[ ! -f "$dst_conf" ]]; then
            cp -p "$src_dir/klaus-delegation.conf" "$dst_conf"
            log_success "Created klaus-delegation.conf"
        else
            log_info "Preserving existing klaus-delegation.conf"
        fi
    fi

    # Install klaus-profiles.conf
    if [[ -f "$src_dir/klaus-profiles.conf" ]]; then
        local dst_profiles="$dst_dir/klaus-profiles.conf"
        if [[ ! -f "$dst_profiles" ]]; then
            cp -p "$src_dir/klaus-profiles.conf" "$dst_profiles"
            log_success "Created klaus-profiles.conf"
        else
            log_info "Preserving existing klaus-profiles.conf"
        fi
    fi

    # Install recursive-agent-config.yaml
    if [[ -f "$src_dir/recursive-agent-config.yaml" ]]; then
        local dst_rlm="$dst_dir/recursive-agent-config.yaml"
        if [[ ! -f "$dst_rlm" ]]; then
            cp -p "$src_dir/recursive-agent-config.yaml" "$dst_rlm"
            log_success "Created recursive-agent-config.yaml"
        else
            log_info "Preserving existing recursive-agent-config.yaml"
        fi
    fi
}

merge_settings_json() {
    local settings_file="$TARGET_DIR/settings.json"
    local hook_command="bash $TARGET_DIR/hooks/klaus-delegation.sh"

    log_info "Configuring settings.json hook..."

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would merge Klaus hook into settings.json"
        return 0
    fi

    # Create settings.json if it doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        mkdir -p "$TARGET_DIR"
        echo '{}' > "$settings_file"
        log_info "Created new settings.json"
    fi

    # Check if Klaus hook already configured
    if grep -q "klaus-delegation.sh" "$settings_file" 2>/dev/null; then
        log_info "Klaus hook already configured in settings.json"
        return 0
    fi

    # Backup settings.json
    cp "$settings_file" "${settings_file}.backup.$(date +%s)"

    # Merge hook using jq (preferred) or Python (fallback)
    if command -v jq &> /dev/null; then
        merge_with_jq "$settings_file" "$hook_command"
    elif command -v python3 &> /dev/null; then
        merge_with_python "$settings_file" "$hook_command"
    else
        log_error "Neither jq nor python3 available for JSON merging"
        log_error "Please install jq: brew install jq (macOS) or apt install jq (Linux)"
        exit 1
    fi

    log_success "Klaus hook merged into settings.json"
}

merge_with_jq() {
    local settings_file="$1"
    local hook_command="$2"

    local temp_file=$(mktemp)

    # Check if UserPromptSubmit hooks already exist
    local existing_hooks=$(jq -r '.hooks.UserPromptSubmit // empty' "$settings_file")

    if [[ -n "$existing_hooks" && "$existing_hooks" != "null" ]]; then
        # APPEND to existing hooks array
        jq --arg hook_cmd "$hook_command" '
            .hooks.UserPromptSubmit += [
                {
                    "matcher": "",
                    "hooks": [
                        {
                            "type": "command",
                            "command": $hook_cmd
                        }
                    ]
                }
            ]
        ' "$settings_file" > "$temp_file"
        log_verbose "Appended Klaus hook to existing UserPromptSubmit hooks"
    else
        # CREATE new hooks structure
        jq --arg hook_cmd "$hook_command" '
            .hooks.UserPromptSubmit = [
                {
                    "matcher": "",
                    "hooks": [
                        {
                            "type": "command",
                            "command": $hook_cmd
                        }
                    ]
                }
            ]
        ' "$settings_file" > "$temp_file"
        log_verbose "Created new UserPromptSubmit hooks array"
    fi

    mv "$temp_file" "$settings_file"
}

merge_with_python() {
    local settings_file="$1"
    local hook_command="$2"

    python3 << EOF
import json
import sys

with open('$settings_file', 'r') as f:
    settings = json.load(f)

if 'hooks' not in settings:
    settings['hooks'] = {}

klaus_hook = {
    'matcher': '',
    'hooks': [
        {
            'type': 'command',
            'command': '$hook_command'
        }
    ]
}

if 'UserPromptSubmit' in settings['hooks']:
    # Append to existing
    settings['hooks']['UserPromptSubmit'].append(klaus_hook)
else:
    # Create new
    settings['hooks']['UserPromptSubmit'] = [klaus_hook]

with open('$settings_file', 'w') as f:
    json.dump(settings, f, indent=2)

print('Merged using Python')
EOF
}

install_plugin_metadata() {
    local src_plugin="$KLAUS_SOURCE/.claude-plugin"
    local dst_plugin="$TARGET_DIR/.claude-plugin"

    if [[ -d "$src_plugin" ]]; then
        log_info "Installing plugin metadata..."

        if [[ "$DRY_RUN" == true ]]; then
            log_info "[DRY-RUN] Would copy .claude-plugin/"
            return 0
        fi

        mkdir -p "$dst_plugin"
        cp -rp "$src_plugin"/* "$dst_plugin/"
        log_success "Installed plugin metadata"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Main Installation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Klaus Baudelaire Installation v${VERSION}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    parse_args "$@"

    log_info "Source: $KLAUS_SOURCE"
    log_info "Target: $TARGET_DIR"
    log_info "Mode: $MODE"
    [[ "$DRY_RUN" == true ]] && log_warn "DRY-RUN MODE - No changes will be made"
    echo ""

    # Validation
    validate_source
    validate_mode

    # Backup existing installation
    create_backup

    # Create target directory
    if [[ "$DRY_RUN" != true ]]; then
        mkdir -p "$TARGET_DIR"
    fi

    echo ""
    log_info "Installing Klaus Baudelaire components..."
    echo ""

    # Install directories
    install_directory "$KLAUS_SOURCE/hooks" "$TARGET_DIR/hooks" "hooks"
    install_directory "$KLAUS_SOURCE/agents" "$TARGET_DIR/agents" "agents"
    install_directory "$KLAUS_SOURCE/commands" "$TARGET_DIR/commands" "commands"

    # Install config (with preservation logic)
    install_config

    # Install plugin metadata
    install_plugin_metadata

    # Merge settings.json (only for non-plugin mode)
    if [[ "$MODE" != "plugin" ]]; then
        echo ""
        merge_settings_json
    fi

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ "$DRY_RUN" == true ]]; then
        echo "  Dry Run Complete"
    else
        echo "  Installation Complete!"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ "$DRY_RUN" != true ]]; then
        log_success "Klaus installed to: $TARGET_DIR"
        echo ""
        echo "Next steps:"
        echo "  1. Restart Claude Code to load the hooks"
        echo "  2. Test with: /klaus-test"
        echo "  3. Initialize project: /fillmemory"
        echo ""

        if [[ -d "$BACKUP_DIR" ]]; then
            echo "Backups stored in: $BACKUP_DIR"
            echo ""
        fi
    fi
}

main "$@"
