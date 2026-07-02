#!/usr/bin/env bash
# Общий helper подсветки tmux-окна для агентских CLI
# (Claude Code, Cursor CLI, Codex, OpenCode).
#
# Ставит опцию окна @claude_alert. Флаг читает window-status-format в
# ~/.config/tmux/tmux.conf и снимает его хук session-window-changed при
# переключении на окно (кроме work/bg — агент ещё работает).
#
# Использование:  agent-alert.sh [--keep-bg] [done|bg|wait|hang|error|work]
#   --keep-bg — «слабый» вызов (idle/wait-уведомления, notify-input.sh):
#               если сейчас стоит bg, ничего не делать — фон ещё бежит,
#               и событие не должно гасить или перекрашивать оранжевый 🔄.
#               Авторитетный done из Stop-хука (фон доехал) зовётся без флага
#               и bg снимает.
#   done  — оранжевый 🔔 (агент завершил ход), по умолчанию
#   bg    — оранжевый 🔄 (ход завершён, фоновые задачи ещё выполняются)
#   wait  — жёлтый ❓ (агент ждёт твоего ответа/разрешения)
#   hang  — фиолетовый ⏳ (завис: тишина в ходе дольше порога watchdog)
#   error — красный ⚠️ (ход прерван ошибкой API)
#   work  — зелёный 🤖 (агент выполняет ход)
#
# work и bg — длящиеся состояния, ставятся БЕЗУСЛОВНО: work — в момент
# отправки промпта окно всегда на виду, метка проявится при уходе с окна;
# bg — фоновые агенты/задачи продолжают работать и после того, как ты
# взглянул на окно, поэтому метка должна пережить переключение (её снимет
# финальный Stop, когда фон доедет). Остальные значения — события: ставятся
# только если окно НЕ на виду. При активном окне done/error (конец хода)
# снимают возможный work/bg — иначе после завершения хода на глазах висела
# бы метка; wait/hang (события посреди хода) ничего не трогают — ход
# продолжится, и work обязан пережить вопрос/паузу. Метку work после ответа
# на AskUserQuestion дополнительно возвращает PostToolUse-хук
# (watchdog-start.sh в ~/.claude/settings.json) — на случай, когда wait/done
# успел перетереть её при неактивном окне.
#
# Текущий pane берётся из $TMUX_PANE процесса-агента (наследуется дочерним
# хуком). Вне tmux — тихо выходит.

keep_bg=0
if [ "$1" = "--keep-bg" ]; then
  keep_bg=1
  shift
fi
alert="${1:-done}"

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

if [ "$keep_bg" = "1" ] && \
   [ "$(tmux display-message -p -t "$TMUX_PANE" '#{@claude_alert}' 2>/dev/null)" = "bg" ]; then
  exit 0
fi

if [ "$alert" != "work" ] && [ "$alert" != "bg" ] && \
   [ "$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)" = "1" ]; then
  # Окно на виду — подсвечивать нечего. Но снимать текущий work/bg можно
  # только по концу хода (done/error). wait/hang — события ПОСРЕДИ хода
  # (вопрос пользователю, пауза): снятие work здесь оставляло бы остаток
  # хода без метки — после ответа на AskUserQuestion её некому вернуть.
  if [ "$alert" = "done" ] || [ "$alert" = "error" ]; then
    tmux set-option -uw -t "$TMUX_PANE" @claude_alert 2>/dev/null
    tmux refresh-client -S 2>/dev/null
  fi
  exit 0
fi

tmux set-option -w -t "$TMUX_PANE" @claude_alert "$alert" 2>/dev/null
tmux refresh-client -S 2>/dev/null
exit 0
