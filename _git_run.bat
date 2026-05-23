@echo off
cd /d C:\Projetos\BX\LCF\back\lcf-backend
set LOG=_git_run_log.txt
echo. > %LOG%

echo [1] STATUS INICIAL >> %LOG%
git status --short >> %LOG% 2>&1

echo [2] ADD ALL >> %LOG%
git add -A >> %LOG% 2>&1
echo exit code git add: %ERRORLEVEL% >> %LOG%

echo [3] STATUS POS-ADD >> %LOG%
git status --short >> %LOG% 2>&1

echo [4] COMMIT >> %LOG%
git commit -m "feat: complete monorepo — Flutter F1 + docs/specs + Sprint 3 modules" >> %LOG% 2>&1
echo exit code git commit: %ERRORLEVEL% >> %LOG%

echo [5] PUSH >> %LOG%
git push >> %LOG% 2>&1
echo exit code git push: %ERRORLEVEL% >> %LOG%

echo [6] LOG FINAL >> %LOG%
git log --oneline -5 >> %LOG% 2>&1

echo Concluido. Ver _git_run_log.txt
type %LOG%
pause
