#!/usr/bin/env bash
# Гасит watchdog зависания текущего tmux-окна. Вызывается из хуков, означающих
# «ход больше не в тишине»: notify-stop.sh (Stop), notify-input.sh (Notification),
# notify-error.sh (StopFailure).

[ -n "$TMUX_PANE" ] || exit 0

pidfile="$HOME/.claude/run/wd-$(printf '%s' "$TMUX_PANE" | tr -cd '0-9').pid"
[ -f "$pidfile" ] && kill "$(cat "$pidfile")" 2>/dev/null
rm -f "$pidfile"

exit 0
