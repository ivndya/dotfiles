#!/bin/bash
# Пересборка ~/.claude/skills из ai-toolkit с исключением ненужных скиллов.
# Запускать после git pull в ai-toolkit (появились новые скиллы) вместо ./install.sh,
# который ставит один общий симлинк на весь каталог skills/ и вернёт всё как было.
set -e

TOOLKIT_SKILLS="$HOME/true_stats/ai-toolkit/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

# Скиллы, которые НЕ подключаем
BLACKLIST=(
  # amoCRM / Wazzup
  amo
  amo-sync-check
  amo-reassign-contact-responsible
  amo-reassign-payment-responsible
  wazzup-summarize
  wazzup-summarize-to-note
  wazzup-draft-reply
  wazzup-create-task
  # TestIT
  testit-cases
  testit-create-case
  testit-create-test-plan
  testit-release-run
  testit-sync
  testit-test-plan-summary
  testit-write-test
  # Клиенты / саппорт TrueStats
  client-investigate
  client-exports
  client-reload-data
  support-agent
  usedesk
  usedesk-vip-sync
  check-redclub
  capabilities
  # Расчёты / финансы
  calc-data-backfill
  calc-migrate-subscription
  calc-refund
  tax-calculation
  net-profit-verify
  financial-consulting-report
  financial-consulting-reconcile
  referral-link-promocode
  admin-user-backend-token
  export-data
)

is_blacklisted() {
  local name="$1"
  for b in "${BLACKLIST[@]}"; do
    [[ "$name" == "$b" ]] && return 0
  done
  return 1
}

# Один общий симлинк (после install.sh) — убираем; каталог — пересобираем.
if [ -L "$CLAUDE_SKILLS" ]; then
  rm "$CLAUDE_SKILLS"
fi
mkdir -p "$CLAUDE_SKILLS"

# Убираем устаревшие симлинки (скилл удалён из репо или добавлен в blacklist)
for link in "$CLAUDE_SKILLS"/*; do
  [ -e "$link" ] || [ -L "$link" ] || continue
  name=$(basename "$link")
  if [ ! -L "$link" ]; then
    echo "SKIP (не симлинк, не трогаю): $name"
    continue
  fi
  if [ ! -d "$TOOLKIT_SKILLS/$name" ] || is_blacklisted "$name"; then
    rm "$link"
    echo "Removed: $name"
  fi
done

# Линкуем всё из репо, кроме blacklist (включая _shared — внутренние файлы скиллов)
added=0
for d in "$TOOLKIT_SKILLS"/*/; do
  name=$(basename "$d")
  is_blacklisted "$name" && continue
  if [ ! -e "$CLAUDE_SKILLS/$name" ]; then
    ln -s "$TOOLKIT_SKILLS/$name" "$CLAUDE_SKILLS/$name"
    echo "Linked: $name"
    added=$((added + 1))
  fi
done

total=$(find "$CLAUDE_SKILLS" -maxdepth 1 -type l | wc -l)
echo ""
echo "Готово: $total симлинков, скрыто ${#BLACKLIST[@]} скиллов из blacklist."
