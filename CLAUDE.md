# Дотфайлы (~ как git-репозиторий)

Правила ниже относятся только к самому дотфайл-репозиторию в `~`.
Вложенные проекты (`~/mcp-pachca`, рабочие репы и т.д.) живут по своим правилам.

## Git-workflow

- В репозитории всегда ровно один коммит — «Initial commit». Новых коммитов
  не создавать: любые изменения амендить в него (`git add <файлы> &&
  git commit --amend --no-edit`) и пушить `git push --force-with-lease`
  (не голый `--force`).
- `.claude/settings.json` помечен `skip-worktree`: поля `model`/`effortLevel`
  постоянно перезаписываются переключателем конфигов, этот churn не коммитим.
  Осознанное изменение настроек: `git update-index --no-skip-worktree
  .claude/settings.json` → коммит → снова `--skip-worktree`.
