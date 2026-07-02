#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook — старт watchdog зависания на новый ход.
# Срабатывает в момент отправки твоего сообщения (до ответа модели).
# Убивает прошлый watchdog окна, ставит зелёную метку work («агент в работе»)
# и запускает новый detached watchdog (переживает возврат хука благодаря setsid).

input=$(cat)

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

transcript=$(printf '%s' "$input" | grep -oP '"transcript_path"\s*:\s*"\K[^"]+' | head -n1)

run="$HOME/.claude/run"
mkdir -p "$run"
pidfile="$run/wd-$(printf '%s' "$TMUX_PANE" | tr -cd '0-9').pid"

# Погасить watchdog прошлого хода, если остался.
[ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
rm -f "$pidfile"

# Новый ход — зелёная метка «агент в работе» (перекрывает прошлую; ставится
# безусловно: сейчас окно активно, метка проявится при уходе с окна).
"$HOME/.config/tmux/agent-alert.sh" work

# Сброс «окно смотрели» (@claude_seen, ставит хук session-window-changed):
# новый ход — новые события; без сброса idle_prompt-напоминание после конца
# хода было бы подавлено навсегда (см. notify-input.sh).
tmux set-option -uw -t "$TMUX_PANE" @claude_seen 2>/dev/null

# Detached watchdog на весь ход; сам запишет свой PID в pidfile.
setsid "$HOME/.claude/hooks/watchdog.sh" "$transcript" "$TMUX_PANE" "$pidfile" \
  </dev/null >/dev/null 2>&1 &

exit 0
