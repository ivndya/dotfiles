#!/usr/bin/env bash
# Claude Code Stop hook -> Windows toast notification (WSL2)
# Reads hook JSON from stdin, fires a native Windows toast via PowerShell.

input=$(cat)

# Отладочный слепок последнего Stop-payload (посмотреть структуру
# background_tasks и т.п.): ~/.claude/run git-ignored, файл перезаписывается.
mkdir -p "$HOME/.claude/run"
printf '%s' "$input" > "$HOME/.claude/run/last-stop.json" 2>/dev/null

# Ход завершён, но фоновая работа может продолжаться: Stop payload несёт массив
# background_tasks — туда попадают и фоновые bash-задачи (type: shell), и фоновые
# субагенты (type: subagent, проверено эмпирически 2026-07). Не пуст → метка bg 🔄
# вместо done 🔔. Когда фон доедет, агент проснётся и финальный Stop поставит done.
alert=done
if printf '%s' "$input" | tr -d ' \n\r\t' | grep -q '"background_tasks":\[[^]]'; then
  alert=bg
fi

# Бейдж 🐚N — сколько фоновых shell-задач ещё бежит (субагентов не считаем).
# Авторитетный пересчёт на каждом Stop: завершение фонового шелла будит агента,
# и следующий Stop обновит число; ноль → agent-shells.sh снимет бейдж.
# Мгновенный инкремент при старте шелла делает shells-up.sh (PostToolUse).
shells=$(printf '%s' "$input" \
  | jq -r '[.background_tasks[]? | select(.type == "shell" and .status == "running")] | length' \
  2>/dev/null)
"$HOME/.config/tmux/agent-shells.sh" "${shells:-0}"

# Try to extract the project dir from the hook payload to make the toast useful.
cwd=$(printf '%s' "$input" | grep -oP '"cwd"\s*:\s*"\K[^"]+' | head -n1)
if [ "$alert" = "bg" ]; then
  message="Агент завершил ход, фоновые задачи ещё выполняются"
else
  message="Агент завершил работу"
fi
if [ -n "$cwd" ]; then
  message="${message}: $(basename "$cwd")"
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ответ пришёл — гасим watchdog зависания.
"${script_dir}/watchdog-cancel.sh"

"${script_dir}/send-toast.sh" "Claude Code" "$message"

# Подсветить tmux-окно ОРАНЖЕВЫМ (🔔 done / 🔄 bg), если окно сейчас не на виду;
# при активном окне helper снимет зелёную метку work. Флаг @claude_alert снимается
# и при переключении на окно (hook session-window-changed, см. ~/.config/tmux/tmux.conf).
"$HOME/.config/tmux/agent-alert.sh" "$alert"

# Never block the agent on notification failure.
exit 0
