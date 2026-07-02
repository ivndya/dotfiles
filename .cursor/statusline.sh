#!/usr/bin/env bash
# Cursor CLI status line. Receives a StatusLinePayload JSON on stdin.
input=$(cat)

MODEL=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
MAXMODE=$(printf '%s' "$input" | jq -r 'if .model.max_mode then " ⚡max" else "" end')
CWD=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "."')
PCT=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
VIM=$(printf '%s' "$input" | jq -r '.vim.mode // empty')

DIR_NAME="${CWD##*/}"

# Normalise percentage to a clean 0-100 integer.
[ -z "$PCT" ] && PCT=0
case "$PCT" in *[!0-9]*) PCT=0 ;; esac
[ "$PCT" -gt 100 ] && PCT=100

# Git branch + dirty marker (scoped to the session cwd).
BRANCH=""
GIT_STATE=""
if git -C "$CWD" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  [ -z "$BRANCH" ] && BRANCH=$(git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
  [ -n "$(git -C "$CWD" status --porcelain 2>/dev/null)" ] && GIT_STATE="*"
fi

RESET="\033[0m"
GRAY="\033[90m"
CYAN="\033[36m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

# Context usage bar.
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

if [ "$PCT" -ge 80 ]; then
  BAR_COLOR="$RED"
elif [ "$PCT" -ge 50 ]; then
  BAR_COLOR="$YELLOW"
else
  BAR_COLOR="$GREEN"
fi

if [ -n "$GIT_STATE" ]; then
  BR_COLOR="$YELLOW"
else
  BR_COLOR="$GREEN"
fi

LINE1="${CYAN}${MODEL}${RESET}${GRAY}${MAXMODE}${RESET} ${GRAY}·${RESET} ${BLUE}${DIR_NAME}${RESET}"
[ -n "$BRANCH" ] && LINE1="${LINE1} ${GRAY}·${RESET} ${BR_COLOR}⎇ ${BRANCH}${GIT_STATE}${RESET}"
[ -n "$VIM" ] && LINE1="${LINE1} ${GRAY}[${VIM}]${RESET}"

LINE2="${GRAY}ctx${RESET} ${BAR_COLOR}${BAR}${RESET} ${GRAY}${PCT}%${RESET}"

printf "%b\n%b" "$LINE1" "$LINE2"
