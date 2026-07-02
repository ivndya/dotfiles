#!/usr/bin/env bash
# Claude Code Notification hook -> Windows toast notification (WSL2)
# Fires when the agent needs your input (permission prompt, idle, etc.).
# Reads hook JSON from stdin and fires a native Windows toast via PowerShell.

input=$(cat)

# The Notification payload carries a human-readable "message" field.
message=$(printf '%s' "$input" | grep -oP '"message"\s*:\s*"\K[^"]+' | head -n1)

# Тип уведомления надёжнее текста message: idle_prompt (Claude закончил и ждёт),
# permission_prompt (нужно разрешение), elicitation_* (форма/вопрос от MCP).
notif_type=$(printf '%s' "$input" | grep -oP '"notification_type"\s*:\s*"\K[^"]+' | head -n1)

# Make the toast more useful by appending the project name.
cwd=$(printf '%s' "$input" | grep -oP '"cwd"\s*:\s*"\K[^"]+' | head -n1)
if [ -n "$cwd" ]; then
  project=$(basename "$cwd")
else
  project=""
fi

if [ -z "$message" ]; then
  message="Агент ждёт ответа"
fi
if [ -n "$project" ]; then
  message="${message} (${project})"
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Claude ждёт ввода/разрешения — это не «тишина», гасим watchdog зависания.
"${script_dir}/watchdog-cancel.sh"

"${script_dir}/send-toast.sh" "Claude Code — нужен ваш ответ" "$message"

# Подсветить tmux-окно, если окно не на виду (при активном окне helper снимет
# зелёную метку work). Цвет — по типу уведомления:
#   idle_prompt (Claude закончил и просто ждёт ввода) → оранжевый done, как при Stop;
#   остальное (permission_prompt / elicitation_* — нужен твой выбор) → жёлтый wait.
# Флаг @claude_alert снимается при переключении на окно (hook session-window-changed).
# --keep-bg: если стоит bg 🔄 (фоновые задачи ещё бегут), уведомление его не
# трогает — иначе idle_prompt через минуту простоя гасил бы метку живого фона.
case "$notif_type" in
  idle_prompt)
    # Окно уже смотрели после начала хода (@claude_seen: ставит хук
    # session-window-changed при переключении на окно, снимает
    # watchdog-start.sh на новом ходе) — ответ прочитан, 🔔 не перезажигать.
    # Без этой проверки idle_prompt через минуту простоя возвращал колокольчик
    # на просмотренную вкладку (баг 2026-07-15).
    if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && \
       [ "$(tmux display-message -p -t "$TMUX_PANE" '#{@claude_seen}' 2>/dev/null)" = "1" ]; then
      exit 0
    fi
    alert=done
    ;;
  *) alert=wait ;;
esac
"$HOME/.config/tmux/agent-alert.sh" --keep-bg "$alert"

# Never block the agent on notification failure.
exit 0
