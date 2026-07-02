#!/usr/bin/env bash
# Cursor CLI `stop` hook — подсветка tmux-окна + Windows toast (WSL2).
# Срабатывает, когда агент завершает цикл (аналог Claude Code Stop).
# Payload приходит JSON'ом в stdin: { "status": "...", "loop_count": N }.

input=$(cat)

# status: completed | aborted | error. aborted — пользователь сам прервал,
# он рядом (окно активно), так что подсветку всё равно отфильтрует agent-alert.
# jq, а не grep -oP: в BSD-grep (macOS) нет PCRE.
status=$(printf '%s' "$input" | jq -r '.status // ""' 2>/dev/null)

# Оранжевый 🔔 «завершил», тем же флагом @claude_alert, что и Claude Code.
"$HOME/.config/tmux/agent-alert.sh" done

# Windows toast через общий тумблер (cnotify on/off управляет ~/.claude/notify-off).
"$HOME/.claude/hooks/send-toast.sh" "Cursor CLI" "Агент завершил работу (${status:-done})"

# Никогда не блокируем агента: пустой вывод = без followup, обычное завершение.
exit 0
