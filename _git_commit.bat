@echo off
cd /d C:\Projetos\BX\LCF\back\lcf-backend

echo === Adicionando tudo ===
git add .claude/PROJECT_STATE.md
git add .claude/sessions/2026-05-22_monorepo_restructure.md
git add CLAUDE.md
git add docs/architecture-overview.md
git add docs/env-checklist.md
git add docs/specs/
git add front/lcf_app/
git add back/src/modules/subscriptions/
git add back/src/modules/tutor-ia/

echo === Status antes do commit ===
git status --short

echo === Commit ===
git commit -m "feat: complete monorepo — Flutter F1 + docs/specs + Sprint 3 WIP modules"

echo === Push ===
git push

echo === Log final ===
git log --oneline -5

echo.
echo === CONCLUIDO ===
pause
