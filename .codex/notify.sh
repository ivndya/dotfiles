#!/usr/bin/env bash
# Codex CLI notify-программа — подсветка tmux-окна + Windows toast (WSL2).
# Codex вызывает её с JSON первым АРГУМЕНТОМ (не stdin) на событиях уведомлений.
# Нас интересует "agent-turn-complete" — агент завершил ход и ждёт тебя.
# Подключается через config.toml:  notify = ["/home/ivan/.codex/notify.sh"]

payload="${1:-}"

# Тип события: реагируем только на завершение хода, прочее игнорируем.
# jq, а не grep -oP: в BSD-grep (macOS) нет PCRE — тип выходил пустым, и
# подсветка не срабатывала вообще.
type=$(printf '%s' "$payload" | jq -r '.type // ""' 2>/dev/null)
[ "$type" = "agent-turn-complete" ] || exit 0

# Оранжевый 🔔 «завершил», тем же флагом @claude_alert, что и Claude Code.
"$HOME/.config/tmux/agent-alert.sh" done

# Windows toast через общий тумблер (cnotify on/off управляет ~/.claude/notify-off).
"$HOME/.claude/hooks/send-toast.sh" "Codex" "Агент завершил работу"

exit 0
