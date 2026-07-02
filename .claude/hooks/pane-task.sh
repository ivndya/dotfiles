#!/usr/bin/env bash
# UserPromptSubmit -> краткая подпись панели tmux (тема сессии по-русски).
#
# Claude Code сам шлёт тему в заголовок терминала (OSC 2, tmux кладёт его в
# #{pane_title}), но язык там плавает: заголовок генерирует служебный запрос,
# и "language": "Russian" из settings.json на него не влияет — половина
# заголовков выходит английской. Поэтому тему берём из ПЕРВОГО промпта
# сессии: он гарантированно на языке пользователя и ничего не стоит.
#
# Пишем в опцию ПАНЕЛИ (-p) @cc_task, её показывает pane-border-format
# (~/.config/tmux/tmux.conf). Индикатор состояния (✳ ждёт / ◐ работает)
# формат берёт первым символом настоящего pane_title, так что подпись
# остаётся живой.
#
# Один раз за сессию: @cc_session хранит id сессии, для которой подпись уже
# зафиксирована. Иначе короткие реплики («и по-русски», «да, давай») затирали
# бы осмысленную тему. Смена сессии в панели (новый claude, /clear, resume)
# даёт другой session_id — подпись перезапишется.
#
# Вне tmux — тихо выходит.

[ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] || exit 0

input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // ""' 2>/dev/null)

prev_sid=$(tmux display-message -p -t "$TMUX_PANE" '#{@cc_session}' 2>/dev/null)
[ -n "$prev_sid" ] && [ "$prev_sid" = "$sid" ] && exit 0

# Промпт в одну строку: переводы строк и табы — в пробелы, лишние пробелы
# схлопнуть. Обрезка sed'ом по СИМВОЛАМ (cut -c в C.UTF-8 режет байты и рубит
# кириллицу пополам); 200 — чтобы не класть в опцию простыню, до ширины панели
# строку дожмёт сам tmux.
task=$(printf '%s' "$input" \
  | jq -r '.prompt // ""' 2>/dev/null \
  | tr '\n\t' '  ' \
  | sed 's/  */ /g; s/^ //; s/ $//; s/\(.\{0,200\}\).*/\1/')

[ -n "$task" ] || exit 0

tmux set-option -p -t "$TMUX_PANE" @cc_task "$task" 2>/dev/null
tmux set-option -p -t "$TMUX_PANE" @cc_session "$sid" 2>/dev/null
tmux refresh-client -S 2>/dev/null
exit 0
