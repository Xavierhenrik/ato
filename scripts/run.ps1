# ATO: sincronizar e rodar
# Execute toda vez que for testar
#
# Uso (na raiz do repositorio): .\scripts\run.ps1
#
# O script puxa atualizacoes do repositorio, recompila dependencias se necessario
# e inicia o app Flutter com as credenciais configuradas.

$ErrorActionPreference = "Stop"

function Write-Step { param($msg) Write-Host "`n[>>] $msg" -ForegroundColor Cyan }
function Write-Ok   { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  [!]  $msg" -ForegroundColor Yellow }
function Write-Fail { param($msg) Write-Host "  [X]  $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "       $msg" -ForegroundColor Gray }

Write-Host ""
Write-Host "  ================================" -ForegroundColor DarkGray
Write-Host "   ATO: iniciando..." -ForegroundColor White
Write-Host "  ================================" -ForegroundColor DarkGray

$repo    = Split-Path $PSScriptRoot -Parent
$appPath = Join-Path $repo "front\ato_app"
$envFile = Join-Path $appPath ".ato-env"

# ── Pre-flight ────────────────────────────────────────────────
if (-not (Test-Path $envFile)) {
    Write-Fail "Credenciais nao encontradas. Execute .\scripts\setup.ps1 primeiro."
    exit 1
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Fail "Flutter nao encontrado no PATH. Execute .\scripts\setup.ps1 primeiro."
    exit 1
}

# ── 1. Git pull ───────────────────────────────────────────────
Write-Step "Sincronizando repositorio"

Set-Location $repo

$headBefore = git rev-parse HEAD 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Nao foi possivel verificar o estado do git. Continuando sem sync."
    $headBefore = $null
}

if ($headBefore) {
    git pull --ff-only 2>&1 | ForEach-Object { Write-Info $_ }

    if ($LASTEXITCODE -ne 0) {
        Write-Warn "git pull falhou (pode haver mudancas locais)."
        Write-Info "Para sincronizar manualmente: git pull"
        Write-Info "Continuando com a versao local..."
        $headBefore = $null
    } else {
        $headAfter = git rev-parse HEAD 2>&1

        if ($headBefore -eq $headAfter) {
            Write-Ok "Ja esta na versao mais recente"
        } else {
            Write-Ok "Atualizacoes baixadas"

            # Verificar se pubspec mudou -> requer pub get
            $changedFiles = git diff --name-only $headBefore $headAfter 2>&1 | Out-String
            if ($changedFiles -match "pubspec") {
                Write-Step "pubspec.yaml alterado, atualizando dependencias"
                Set-Location $appPath
                flutter pub get
                if ($LASTEXITCODE -ne 0) {
                    Write-Fail "flutter pub get falhou. Verifique a conexao e tente novamente."
                    exit 1
                }
                Write-Ok "Dependencias atualizadas"
            }
        }
    }
}

# ── 2. Carregar credenciais ───────────────────────────────────
Write-Step "Carregando credenciais"

$cfg = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^([^#][^=]*)=(.*)$") {
        $cfg[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

$apiUrl  = $cfg["API_BASE_URL"]
$supUrl  = $cfg["SUPABASE_URL"]
$supAnon = $cfg["SUPABASE_ANON_KEY"]

if (-not $apiUrl -or -not $supUrl -or -not $supAnon) {
    Write-Fail "Credenciais incompletas em $envFile"
    Write-Info "Delete o arquivo e rode .\scripts\setup.ps1 novamente para reconfigurar."
    exit 1
}

Write-Ok "Backend: $apiUrl"
Write-Ok "Supabase: $supUrl"

# ── 3. Verificar dispositivo ──────────────────────────────────
Write-Step "Verificando dispositivos"

Set-Location $appPath
$devOutput = flutter devices 2>&1 | Out-String
$hasDevice = $devOutput -match "android|emulator"

if (-not $hasDevice) {
    Write-Fail "Nenhum emulador ou dispositivo detectado."
    Write-Info ""
    Write-Info "Inicie um emulador no Android Studio:"
    Write-Info "  Tools > Device Manager > clique no play ao lado do emulador"
    Write-Info ""
    Write-Info "Ou conecte um celular Android com depuracao USB habilitada."
    Write-Info "Depois rode .\scripts\run.ps1 novamente."
    exit 1
}

Write-Ok "Dispositivo pronto"

# ── 4. Rodar ──────────────────────────────────────────────────
Write-Step "Iniciando ATO"
Write-Host ""

$runArgs = @(
    "run"
    "--dart-define=API_BASE_URL=$apiUrl"
    "--dart-define=SUPABASE_URL=$supUrl"
    "--dart-define=SUPABASE_ANON_KEY=$supAnon"
)

& flutter @runArgs
