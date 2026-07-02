#!/usr/bin/env bash
# Claude Code PreCompact + SessionStart(source=compact) — подсветка tmux-окна
# на время сжатия контекста (compact). Оба события ведут в этот скрипт,
# ветвление по hook_event_name.
#
# PreCompact (trigger: auto|manual) — сжатие началось: метка compact 🗜️
# (голубая), длящееся состояние — переживает переключение окон и рисуется
# на активной вкладке. Триггер запоминается в
# ~/.claude/run/compact-<session_id>.trigger — SessionStart-payload его не несёт.
# Watchdog при метке compact пережидает (транскрипт молчит, но это не «завис»).
#
# SessionStart source=compact — сжатие закончилось:
#   auto   — сжатие случилось посреди хода, ход продолжается → work 🤖
#            (watchdog жив и дальше следит сам);
#   manual — /compact запускал пользователь, сессия снова ждёт ввода → done 🔔
#            (событие: при активном окне helper просто снимет метку).
# Если сжатие оборвалось без SessionStart (ошибка, Esc), метка compact
# самоисцелится следующим событием: UserPromptSubmit → work, Stop → done.

input=$(cat)

# jq, а не grep -oP: в BSD-grep (macOS) нет PCRE.
event=$(printf '%s' "$input" | jq -r '.hook_event_name // ""' 2>/dev/null)
sid=$(printf '%s' "$input" | jq -r '.session_id // ""' 2>/dev/null)

run="$HOME/.claude/run"
mkdir -p "$run"
trigger_file="$run/compact-${sid:-unknown}.trigger"

case "$event" in
  PreCompact)
    trigger=$(printf '%s' "$input" | jq -r '.trigger // ""' 2>/dev/null)
    printf '%s' "${trigger:-auto}" > "$trigger_file"
    "$HOME/.config/tmux/agent-alert.sh" compact
    ;;
  SessionStart)
    # Страховка от расширения matcher'а: реагируем только на конец сжатия.
    source=$(printf '%s' "$input" | jq -r '.source // ""' 2>/dev/null)
    [ "$source" = "compact" ] || exit 0
    trigger=$(cat "$trigger_file" 2>/dev/null)
    rm -f "$trigger_file"
    if [ "$trigger" = "manual" ]; then
      "$HOME/.config/tmux/agent-alert.sh" done
    else
      "$HOME/.config/tmux/agent-alert.sh" work
    fi
    ;;
esac

# Never block the agent on notification failure.
exit 0
