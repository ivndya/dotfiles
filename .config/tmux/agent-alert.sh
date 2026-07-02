#!/usr/bin/env bash
# Общий helper подсветки tmux-окна для агентских CLI
# (Claude Code, Cursor CLI, Codex, OpenCode).
#
# Ставит опцию окна @claude_alert. Флаг читает window-status-format в
# ~/.config/tmux/tmux.conf и снимает его хук session-window-changed при
# переключении на окно (кроме work/bg/compact — агент ещё работает).
#
# Использование:  agent-alert.sh [--keep-bg] [done|bg|wait|hang|error|work|compact]
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
#   compact — голубой 🗜️ (идёт сжатие контекста: PreCompact → SessionStart)
#
# work, bg и compact — длящиеся состояния, ставятся БЕЗУСЛОВНО: work — в момент
# отправки промпта окно всегда на виду, метка проявится при уходе с окна;
# bg — фоновые агенты/задачи продолжают работать и после того, как ты
# взглянул на окно, поэтому метка должна пережить переключение (её снимет
# финальный Stop, когда фон доедет); compact — сжатие контекста тоже идёт
# независимо от взгляда на окно (метку снимет notify-compact.sh на
# SessionStart source=compact по концу сжатия). Остальные значения — события: ставятся
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

# Трассировка переходов метки: кто, когда, что просил, что стояло, чем кончилось.
# ~/.claude/run git-ignored; лог append-only, чистится вручную.
_log() {
  printf '%s pane=%s by=%s ask=%s keep_bg=%s prev=%s active=%s -> %s\n' \
    "$(date +%H:%M:%S)" "$TMUX_PANE" "$(ps -o args= -p "$PPID" 2>/dev/null | awk '{print $NF}' | xargs -r basename)" \
    "$alert" "$keep_bg" "${prev:-<none>}" "${active:-?}" "$1" \
    >> "$HOME/.claude/run/alerts.log" 2>/dev/null
}
prev=$(tmux display-message -p -t "$TMUX_PANE" '#{@claude_alert}' 2>/dev/null)
active=$(tmux display-message -p -t "$TMUX_PANE" '#{window_active}' 2>/dev/null)

if [ "$keep_bg" = "1" ] && [ "$prev" = "bg" ]; then
  _log "skip (bg жив)"
  exit 0
fi

if [ "$alert" != "work" ] && [ "$alert" != "bg" ] && [ "$alert" != "compact" ] && \
   [ "$active" = "1" ]; then
  # Окно на виду — подсвечивать нечего. Но снимать текущий work/bg можно
  # только по концу хода (done/error). wait/hang — события ПОСРЕДИ хода
  # (вопрос пользователю, пауза): снятие work здесь оставляло бы остаток
  # хода без метки — после ответа на AskUserQuestion её некому вернуть.
  if [ "$alert" = "done" ] || [ "$alert" = "error" ]; then
    tmux set-option -uw -t "$TMUX_PANE" @claude_alert 2>/dev/null
    tmux refresh-client -S 2>/dev/null
    _log "снял метку (окно активно)"
  else
    _log "skip (окно активно)"
  fi
  exit 0
fi

tmux set-option -w -t "$TMUX_PANE" @claude_alert "$alert" 2>/dev/null
tmux refresh-client -S 2>/dev/null
_log "поставил $alert"
exit 0
