#!/bin/bash
# analyze-routing-accuracy.sh - Analyze routing telemetry data
# Part of Klaus System B1 - Routing outcome tracking

set -euo pipefail

KLAUS_ROOT="${KLAUS_ROOT:-${HOME}/.claude}"
HISTORY_FILE="${KLAUS_ROOT}/telemetry/routing-history.jsonl"

# [!] Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
  cat <<EOF
Usage: analyze-routing-accuracy.sh [OPTIONS]

Analyze Klaus routing telemetry data to understand tier distribution and patterns.

OPTIONS:
  -h, --help          Show this help message
  -f, --file FILE     Specify telemetry file (default: ~/.claude/telemetry/routing-history.jsonl)
  -d, --days N        Analyze last N days (default: 7)
  -t, --tier TIER     Filter by tier (DIRECT, LIGHT, MEDIUM, FULL)
  -s, --stats         Show detailed statistics

EXAMPLES:
  # Basic analysis
  analyze-routing-accuracy.sh

  # Last 30 days with stats
  analyze-routing-accuracy.sh --days 30 --stats

  # Filter by FULL tier only
  analyze-routing-accuracy.sh --tier FULL

EOF
  exit 0
}

# Parse arguments
DAYS=7
TIER_FILTER=""
SHOW_STATS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) usage ;;
    -f|--file) HISTORY_FILE="$2"; shift 2 ;;
    -d|--days) DAYS="$2"; shift 2 ;;
    -t|--tier) TIER_FILTER="$2"; shift 2 ;;
    -s|--stats) SHOW_STATS=true; shift ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# [!] Check telemetry file exists
if [[ ! -f "$HISTORY_FILE" ]]; then
  echo -e "${RED}✗${NC} Telemetry file not found: $HISTORY_FILE"
  echo ""
  echo "Telemetry is disabled by default. To enable:"
  echo "  1. Edit ~/.claude/klaus-delegation.conf"
  echo "  2. Set ENABLE_ROUTING_HISTORY=\"ON\""
  echo "  3. Use Klaus normally"
  echo ""
  exit 1
fi

# [!] Check jq installed
if ! command -v jq &> /dev/null; then
  echo -e "${RED}✗${NC} jq is required but not installed"
  echo "  Install: brew install jq"
  exit 1
fi

# [!] Filter entries by date
CUTOFF_DATE=$(date -u -v-${DAYS}d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "${DAYS} days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)

FILTERED_DATA=$(jq -c --arg cutoff "$CUTOFF_DATE" 'select(.timestamp >= $cutoff)' "$HISTORY_FILE")

# Apply tier filter if specified
if [[ -n "$TIER_FILTER" ]]; then
  FILTERED_DATA=$(echo "$FILTERED_DATA" | jq -c --arg tier "$TIER_FILTER" 'select(.tier == $tier)')
fi

# [!] Count total entries
TOTAL=$(echo "$FILTERED_DATA" | wc -l | tr -d ' ')

if [[ "$TOTAL" -eq 0 ]]; then
  echo -e "${YELLOW}⚠${NC} No telemetry entries found in last $DAYS days"
  exit 0
fi

# [!] Summary header
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Klaus Routing Telemetry Analysis${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Period: Last $DAYS days"
echo "Total routing decisions: $TOTAL"
echo ""

# [!] Tier distribution
echo "Tier Distribution:"
echo "$FILTERED_DATA" | jq -r '.tier' | sort | uniq -c | sort -rn | while read count tier; do
  percentage=$(awk "BEGIN {printf \"%.1f\", ($count/$TOTAL)*100}")
  case "$tier" in
    "DIRECT")  echo -e "  ${GREEN}●${NC} $tier: $count (${percentage}%)" ;;
    "LIGHT")   echo -e "  ${BLUE}●${NC} $tier: $count (${percentage}%)" ;;
    "MEDIUM")  echo -e "  ${YELLOW}●${NC} $tier: $count (${percentage}%)" ;;
    "FULL")    echo -e "  ${RED}●${NC} $tier: $count (${percentage}%)" ;;
  esac
done

# [!] Score statistics
if [[ "$SHOW_STATS" == true ]]; then
  echo ""
  echo "Score Statistics:"

  AVG_SCORE=$(echo "$FILTERED_DATA" | jq -r '.score' | awk '{sum+=$1; count++} END {printf "%.1f", sum/count}')
  MIN_SCORE=$(echo "$FILTERED_DATA" | jq -r '.score' | sort -n | head -1)
  MAX_SCORE=$(echo "$FILTERED_DATA" | jq -r '.score' | sort -n | tail -1)

  echo "  Average: $AVG_SCORE"
  echo "  Range: $MIN_SCORE - $MAX_SCORE"

  # Context7 detection rate
  C7_COUNT=$(echo "$FILTERED_DATA" | jq -r 'select(.context7_relevant == true)' | wc -l | tr -d ' ')
  C7_PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($C7_COUNT/$TOTAL)*100}")
  echo ""
  echo "Context7 Documentation:"
  echo "  Detected: $C7_COUNT / $TOTAL (${C7_PERCENTAGE}%)"

  # Prompt length statistics
  AVG_LENGTH=$(echo "$FILTERED_DATA" | jq -r '.prompt_length' | awk '{sum+=$1; count++} END {printf "%.0f", sum/count}')
  echo ""
  echo "Prompt Length:"
  echo "  Average: $AVG_LENGTH characters"
fi

# [!] Recent entries (last 5)
echo ""
echo "Recent Routing Decisions (last 5):"
echo "$FILTERED_DATA" | tail -5 | jq -r '[.timestamp, .tier, "score: " + (.score|tostring), "len: " + (.prompt_length|tostring)] | @tsv' | while IFS=$'\t' read timestamp tier score length; do
  case "$tier" in
    "DIRECT")  echo -e "  ${GREEN}●${NC} $(date -jf "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$timestamp") | $tier | $score | $length" ;;
    "LIGHT")   echo -e "  ${BLUE}●${NC} $(date -jf "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$timestamp") | $tier | $score | $length" ;;
    "MEDIUM")  echo -e "  ${YELLOW}●${NC} $(date -jf "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$timestamp") | $tier | $score | $length" ;;
    "FULL")    echo -e "  ${RED}●${NC} $(date -jf "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$timestamp") | $tier | $score | $length" ;;
  esac
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
