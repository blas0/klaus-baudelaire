#!/usr/bin/env bash
# hooks/rlm-workflow-coordinator.sh
# SubagentStop hook for RLM workflow orchestration
#
# Coordinates background subagent completion and workflow progression.
# Triggered when chunk-analyzer, conflict-resolver, or synthesis-agent completes.
#
# Exit codes:
#   0 = Continue workflow (spawn next agent)
#   1 = Error (halt workflow)
#   2 = Signal continuation needed (more chunks to process)
#   3 = Workflow complete (no action needed)

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/recursive-agent-config.yaml"

# Default values (overridden by config)
MAX_PARALLEL_WORKERS=5
CHUNKING_SIZE=25000
OVERLAP_PERCENT=15

# ============================================================================
# Utility Functions
# ============================================================================

log() {
    echo "[rlm-coordinator] $*" >&2
}

error() {
    echo "[rlm-coordinator ERROR] $*" >&2
}

# Load configuration from YAML file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading config from $CONFIG_FILE"
        # Simple YAML parsing for our specific config structure
        if command -v yq &>/dev/null; then
            MAX_PARALLEL_WORKERS=$(yq eval '.patterns.map_reduce.max_parallel_workers // 5' "$CONFIG_FILE")
            CHUNKING_SIZE=$(yq eval '.chunking.default_size // 25000' "$CONFIG_FILE")
            OVERLAP_PERCENT=$(yq eval '.chunking.overlap_percent // 15' "$CONFIG_FILE")
        else
            log "yq not found, using default config values"
        fi
    else
        log "Config file not found, using defaults"
    fi
}

# Extract subagent type from arguments
get_subagent_type() {
    # $SUBAGENT_TYPE environment variable set by hook system
    echo "${SUBAGENT_TYPE:-unknown}"
}

# Get parent task ID from environment or arguments
get_parent_task_id() {
    # $PARENT_TASK_ID environment variable set by hook system
    echo "${PARENT_TASK_ID:-}"
}

# Read task state via TaskGet
read_task_state() {
    local task_id="$1"

    if [[ -z "$task_id" ]]; then
        error "No task ID provided to read_task_state"
        return 1
    fi

    # Use claude command to read task via TaskGet
    # This is a placeholder - actual implementation depends on CLI interface
    # In practice, hook receives task state via environment variables
    if [[ -n "${TASK_STATE:-}" ]]; then
        echo "$TASK_STATE"
    else
        error "TASK_STATE environment variable not set"
        return 1
    fi
}

# Parse JSON field from task state
parse_json_field() {
    local json="$1"
    local field="$2"

    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".$field // empty"
    else
        # Fallback: simple grep/sed parsing (fragile, but works for basic cases)
        echo "$json" | grep -o "\"$field\"[^,}]*" | sed 's/.*: *"\?\([^"]*\)"\?.*/\1/'
    fi
}

# ============================================================================
# Workflow Coordination Logic
# ============================================================================

# Handle chunk-analyzer completion
handle_chunk_analyzer_stop() {
    log "chunk-analyzer completed"

    local parent_task_id
    parent_task_id=$(get_parent_task_id)

    if [[ -z "$parent_task_id" ]]; then
        error "No parent task ID found"
        return 1
    fi

    # Read parent task state
    local task_state
    task_state=$(read_task_state "$parent_task_id")

    if [[ -z "$task_state" ]]; then
        error "Could not read parent task state"
        return 1
    fi

    # Extract state fields
    local pattern
    local chunks_processed
    local total_chunks
    local background_task_ids

    pattern=$(parse_json_field "$task_state" "pattern")
    chunks_processed=$(parse_json_field "$task_state" "chunks_processed")
    total_chunks=$(parse_json_field "$task_state" "total_chunks")
    background_task_ids=$(parse_json_field "$task_state" "background_task_ids")

    log "Pattern: $pattern"
    log "Progress: $chunks_processed/$total_chunks chunks"

    # Check if more chunks remain
    if [[ "$chunks_processed" -lt "$total_chunks" ]]; then
        log "More chunks remaining, signaling continuation needed"
        return 2  # Signal continuation
    fi

    # All chunks processed, check pattern
    case "$pattern" in
        map-reduce)
            log "Map-Reduce pattern: All chunks complete, trigger conflict-resolver"
            # Orchestrator will spawn conflict-resolver next
            return 0
            ;;
        refine)
            log "Refine pattern: All chunks complete, trigger synthesis-agent"
            # Orchestrator will spawn synthesis-agent next
            return 0
            ;;
        scratchpad)
            log "Scratchpad pattern: Check investigation queue"
            # Orchestrator will check if more investigations needed
            return 0
            ;;
        *)
            error "Unknown pattern: $pattern"
            return 1
            ;;
    esac
}

# Handle conflict-resolver completion
handle_conflict_resolver_stop() {
    log "conflict-resolver completed"

    local parent_task_id
    parent_task_id=$(get_parent_task_id)

    if [[ -z "$parent_task_id" ]]; then
        error "No parent task ID found"
        return 1
    fi

    # Read parent task state
    local task_state
    task_state=$(read_task_state "$parent_task_id")

    if [[ -z "$task_state" ]]; then
        error "Could not read parent task state"
        return 1
    fi

    # Extract deduplication statistics
    local dedup_rate
    dedup_rate=$(parse_json_field "$task_state" "deduplication_stats.rate")

    log "Deduplication complete (rate: ${dedup_rate:-unknown})"
    log "Triggering synthesis-agent for final report"

    # Orchestrator will spawn synthesis-agent next
    return 0
}

# Handle synthesis-agent completion
handle_synthesis_agent_stop() {
    log "synthesis-agent completed"

    local parent_task_id
    parent_task_id=$(get_parent_task_id)

    if [[ -z "$parent_task_id" ]]; then
        error "No parent task ID found"
        return 1
    fi

    # Read parent task state
    local task_state
    task_state=$(read_task_state "$parent_task_id")

    if [[ -z "$task_state" ]]; then
        error "Could not read parent task state"
        return 1
    fi

    # Check if final report was generated
    local report_generated
    report_generated=$(parse_json_field "$task_state" "report_generated_at")

    if [[ -n "$report_generated" ]]; then
        log "Final report generated at: $report_generated"
        log "Workflow complete"
        return 3  # Workflow complete
    else
        error "synthesis-agent completed but no report_generated_at timestamp found"
        return 1
    fi
}

# ============================================================================
# Main Entry Point
# ============================================================================

main() {
    log "Starting RLM workflow coordinator"

    # Load configuration
    load_config

    # Determine which subagent just stopped
    local subagent_type
    subagent_type=$(get_subagent_type)

    log "Handling stop event for: $subagent_type"

    # Route to appropriate handler
    case "$subagent_type" in
        chunk-analyzer)
            handle_chunk_analyzer_stop
            ;;
        conflict-resolver)
            handle_conflict_resolver_stop
            ;;
        synthesis-agent)
            handle_synthesis_agent_stop
            ;;
        *)
            error "Unknown subagent type: $subagent_type"
            return 1
            ;;
    esac
}

# ============================================================================
# Execute
# ============================================================================

# Run main function and exit with its code
main "$@"
exit $?
