#!/usr/bin/env bash
# Claude Code PostToolUse hook (matcher: Bash) — мгновенный бейдж 🐚 при
# старте фоновой shell-задачи (tool_input.run_in_background: true), не
# дожидаясь конца хода. Оптимистичный инкремент текущего @claude_shells;
# авторитетный пересчёт делает notify-stop.sh на каждом Stop по
# background_tasks — он же чинит гонку параллельных инкрементов в одном
# батче и снимает бейдж, когда бегущих шеллов не осталось.

input=$(cat)

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

# Именно поле tool_input.run_in_background, а не подстрока в payload:
# текст команды может содержать что угодно (например, этот скрипт).
bg=$(printf '%s' "$input" | jq -r '.tool_input.run_in_background == true' 2>/dev/null)
[ "$bg" = "true" ] || exit 0

current=$(tmux show-options -wqv -t "$TMUX_PANE" @claude_shells 2>/dev/null)
case "$current" in (''|*[!0-9]*) current=0;; esac

"$HOME/.config/tmux/agent-shells.sh" $((current + 1))
exit 0
