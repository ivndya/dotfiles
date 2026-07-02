#!/usr/bin/env bash
# Бейдж количества фоновых shell-задач Claude Code на вкладке tmux.
#
# Ставит/снимает опцию окна @claude_shells (целое ≥1 — сколько фоновых
# шеллов бежит). Опцию читает window-status-format в ~/.config/tmux/tmux.conf:
# у неактивной вкладки появляется голубой хвост « 🐚N». Это длящееся
# состояние (как work/bg у @claude_alert): ставится безусловно, переживает
# переключение окон (after-select-window его не трогает); снимается только
# пересчётом в ноль — Stop-хуком, когда бегущих шеллов не осталось, или
# SessionEnd-хуком при выходе из Claude (иначе бейдж осиротевшего шелла
# висел бы вечно).
#
# Использование: agent-shells.sh <N>
#   N ≥ 1              — показать бейдж с числом N
#   N = 0 / пусто / мусор — снять бейдж
#
# Текущий pane берётся из $TMUX_PANE процесса-агента (наследуется хуком).
# Вне tmux — тихо выходит.

n="${1:-0}"
case "$n" in (''|*[!0-9]*) n=0;; esac

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

if [ "$n" -ge 1 ]; then
  tmux set-option -w -t "$TMUX_PANE" @claude_shells "$n" 2>/dev/null
else
  tmux set-option -uw -t "$TMUX_PANE" @claude_shells 2>/dev/null
fi
tmux refresh-client -S 2>/dev/null
exit 0
