@echo off
cd /d C:\Projetos\BX\LCF\back\lcf-backend

echo === Verificando estado atual ===
git status --short > _git_status.txt 2>&1
git log --oneline -5 >> _git_status.txt 2>&1

echo === Restaurando modulos deletados do disco ===
git checkout HEAD -- back/src/modules/

echo === Adicionando front/lcf_app ===
git add front/lcf_app

echo === Adicionando docs ===
git add docs/specs
git add docs/architecture-overview.md
git add docs/env-checklist.md
git add front/docs

echo === Adicionando CLAUDE.md e PROJECT_STATE ===
git add CLAUDE.md
git add .claude/PROJECT_STATE.md

echo === Verificando o que sera commitado ===
git status >> _git_status.txt 2>&1

echo === Commit ===
git commit -m "feat: complete monorepo — Flutter F1 + docs/specs + env-checklist + architecture + restore src/modules"

echo === Push ===
git push

echo === CONCLUIDO ===
git log --oneline -4 >> _git_status.txt 2>&1
pause
