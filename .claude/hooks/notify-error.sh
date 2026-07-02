#!/usr/bin/env bash
# Claude Code StopFailure hook — ход прерван ошибкой API (overloaded/rate_limit/
# server_error и пр., см. matcher в settings.json). Помечает tmux-окно КРАСНЫМ ⚠️
# (если окно не на виду) + Windows toast. Гасит watchdog зависания.
# Output/exit code Claude Code для StopFailure игнорирует — это чистый side effect.

input=$(cat)

# Тип ошибки, если он есть в payload — только для текста toast (метка одна на все типы).
err=$(printf '%s' "$input" | grep -oP '"(error_type|reason|type)"\s*:\s*"\K[^"]+' | head -n1)

# Ход завершился (пусть и ошибкой) — это не «тишина», гасим watchdog.
"$HOME/.claude/hooks/watchdog-cancel.sh"

# Красный ⚠️, если окно не на виду.
"$HOME/.config/tmux/agent-alert.sh" error

# Windows toast через общий тумблер cnotify.
"$HOME/.claude/hooks/send-toast.sh" "Claude Code — ошибка API" "Ход прерван${err:+: $err}"

exit 0
