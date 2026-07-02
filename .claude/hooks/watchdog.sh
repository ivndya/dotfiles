#!/usr/bin/env bash
# Watchdog зависания Claude Code. Запускается detached (setsid) из
# UserPromptSubmit-хука на весь ход и следит за mtime файла транскрипта:
# пока Claude активен (пишет сообщения/тулколлы/результаты), mtime свежий.
# Тишина дольше порога — окно помечается «завис» (⏳ фиолетовый); активность
# вернулась — снова «в работе» (🤖 зелёный). Живёт до конца хода: hang не
# терминален, поэтому ложный «завис» (долгий tool call) самоисправляется,
# а метка, снятая хуком session-window-changed (заглянул на окно), через шаг
# проверки восстанавливается. Гасится watchdog-cancel.sh (из Stop /
# Notification / StopFailure) убийством по PID из pidfile, либо перезаписью
# pidfile при новом промпте.
#
# Аргументы: <transcript_path> <tmux_pane> <pidfile>

transcript="$1"
pane="$2"
pidfile="$3"
threshold=300   # 5 минут тишины = «завис»
interval=30     # шаг проверки

# Самоидентификация: этот PID — текущий активный watchdog данного окна.
echo "$$" > "$pidfile"

# mtime файла в секундах. BSD (macOS) — `stat -f %m`, GNU (Linux/WSL) — `stat -c %Y`;
# дотфайлы живут на обеих системах, поэтому пробуем оба. Пусто — файла нет.
_mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null; }

while :; do
  sleep "$interval"
  # pidfile перезаписан новым watchdog (новый промпт) или удалён (cancel) — выходим.
  [ "$(cat "$pidfile" 2>/dev/null)" = "$$" ] || exit 0
  [ -f "$transcript" ] || continue

  now=$(date +%s)
  # Активность = свежайший mtime среди основного транскрипта и транскриптов
  # субагентов (<session>/subagents/*.jsonl): пока работает Task-субагент,
  # основной файл стоит — пишется только субагентский.
  mt=$(_mtime "$transcript"); [ -n "$mt" ] || mt=$now
  # Без `find -printf` — его нет в BSD-find (macOS). Глоб + _mtime работают везде.
  smt=$(for f in "${transcript%.jsonl}"/subagents/*.jsonl; do
          [ -f "$f" ] && _mtime "$f"
        done | sort -rn | head -n1)
  [ -n "$smt" ] && [ "$smt" -gt "$mt" ] && mt=$smt
  if [ $(( now - mt )) -ge "$threshold" ]; then desired=hang; else desired=work; fi

  # done/bg/wait/error — ход завершён или агент ждёт ответа (гонка с cancel,
  # который вот-вот нас убьёт): метка больше не наша, не перетираем.
  # compact — идёт сжатие контекста (PreCompact): транскрипт молчит, но это
  # не «завис» — пережидаем, метку не трогаем; по концу сжатия
  # notify-compact.sh вернёт work, и слежка продолжится.
  current=$(tmux show-options -wqv -t "$pane" @claude_alert 2>/dev/null)
  case "$current" in ""|work|hang) ;; compact) continue ;; *) exit 0 ;; esac
  [ "$current" = "$desired" ] && continue

  TMUX_PANE="$pane" "$HOME/.config/tmux/agent-alert.sh" "$desired"
done
