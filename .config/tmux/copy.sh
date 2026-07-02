#!/usr/bin/env bash
# Копирование stdin в системный буфер обмена — одинаково на macOS и WSL/Linux.
# Зовётся из tmux.conf: copy-pipe-and-cancel "~/.config/tmux/copy.sh".
#
# Раньше в бинде стоял голый `wl-copy` (буфер Wayland/WSLg). На маке его нет,
# и выделение по `y` в copy-mode молча никуда не попадало — терялось между
# tmux-буфером и системным (найдено 2026-08-31).
#
# Порядок: pbcopy (macOS) → wl-copy (Wayland/WSLg) → xclip/xsel (X11).
# Если ничего не нашлось — просто съедаем ввод: копия всё равно осталась
# в буфере tmux (prefix ] вставит её), падать смысла нет.

if command -v pbcopy >/dev/null 2>&1; then
  exec pbcopy
elif command -v wl-copy >/dev/null 2>&1; then
  exec wl-copy
elif command -v xclip >/dev/null 2>&1; then
  exec xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  exec xsel --clipboard --input
else
  cat >/dev/null
fi
