# ATO: setup inicial
# Execute uma vez apos clonar o repositorio
#
# Uso (na raiz do repositorio): .\scripts\setup.ps1
#
# O script verifica pre-requisitos, solicita credenciais quando necessario
# e prepara o ambiente para rodar o app Flutter.

$ErrorActionPreference = "Stop"
$appName = "ATO"

function Write-Step { param($msg) Write-Host "`n[>>] $msg" -ForegroundColor Cyan }
function Write-Ok   { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  [!]  $msg" -ForegroundColor Yellow }
function Write-Fail { param($msg) Write-Host "  [X]  $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "       $msg" -ForegroundColor Gray }
function Wait-User  { param($msg) Write-Host "`n  >>> $msg" -ForegroundColor Yellow; Read-Host "  Pressione ENTER quando pronto" | Out-Null }

Write-Host ""
Write-Host "  ================================" -ForegroundColor DarkGray
Write-Host "   ${appName}: setup do ambiente" -ForegroundColor White
Write-Host "  ================================" -ForegroundColor DarkGray

# ── 0. Localizar repositorio ─────────────────────────────────
Write-Step "Verificando estrutura de pastas"

$repo    = Split-Path $PSScriptRoot -Parent
$appPath = Join-Path $repo "front\ato_app"
$envFile = Join-Path $appPath ".ato-env"

if (-not (Test-Path $appPath)) {
    Write-Fail "Pasta 'front\ato_app' nao encontrada em: $repo"
    Write-Info "O repositorio pode estar em um estado incompleto. Verifique com o Henrique."
    exit 1
}

Write-Ok "Repositorio encontrado em: $repo"

# ── 1. Flutter SDK ────────────────────────────────────────────
Write-Step "Verificando Flutter SDK"

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Fail "Flutter nao encontrado no PATH."
    Write-Info ""
    Write-Info "Instale o Flutter SDK:"
    Write-Info "  https://docs.flutter.dev/get-started/install/windows"
    Write-Info ""
    Write-Info "Passos:"
    Write-Info "  1. Baixe o SDK e extraia em C:\src\flutter (ou outro diretorio sem espacos)"
    Write-Info "  2. Adicione C:\src\flutter\bin ao PATH do sistema"
    Write-Info "  3. Abra um novo terminal e rode: flutter doctor"
    Write-Info ""
    Wait-User "Instale o Flutter, adicione ao PATH, abra um NOVO terminal e rode .\setup.ps1 novamente."
    exit 1
}

try {
    $flutterVer = (flutter --version 2>&1 | Select-String "Flutter \d").Matches[0].Value
    Write-Ok "$flutterVer detectado"
} catch {
    Write-Ok "Flutter encontrado (versao nao detectada, continue)"
}

# ── 2. Android SDK / Emulador ─────────────────────────────────
Write-Step "Verificando emuladores Android"

$devices = flutter devices 2>&1
$hasDevice = ($devices | Out-String) -match "android|emulator"

if (-not $hasDevice) {
    Write-Warn "Nenhum emulador Android detectado ainda."
    Write-Info ""
    Write-Info "Para criar um emulador:"
    Write-Info "  1. Instale o Android Studio: https://developer.android.com/studio"
    Write-Info "  2. Abra Android Studio > Tools > Device Manager"
    Write-Info "  3. Clique em 'Create Device'"
    Write-Info "  4. Escolha: Pixel 8, API 35 (ou superior)"
    Write-Info "  5. Inicie o emulador"
    Write-Info ""
    Write-Info "Voce pode continuar o setup e iniciar o emulador depois."
    Write-Info "Para dispositivo fisico: habilite 'Depuracao USB' nas opcoes do desenvolvedor."
} else {
    Write-Ok "Dispositivo encontrado"
    Write-Host ($devices | Out-String).Trim() | ForEach-Object { Write-Info $_ }
}

# ── 3. Credenciais ────────────────────────────────────────────
Write-Step "Verificando credenciais"

if (Test-Path $envFile) {
    Write-Ok "Credenciais encontradas em $envFile"
    Write-Info "(Para alterar, delete o arquivo e rode setup.ps1 novamente)"
} else {
    Write-Warn "Arquivo de credenciais nao encontrado, precisamos configura-lo."
    Write-Info ""
    Write-Info "Voce precisara de dois valores que o Henrique deve te passar:"
    Write-Info "  - SUPABASE_URL    (ex: https://abcxyz.supabase.co)"
    Write-Info "  - SUPABASE_ANON_KEY  (chave publica, comeca com eyJ...)"
    Write-Info ""
    Write-Info "O app usara o backend ja publicado (Railway), sem backend local."
    Write-Host ""

    $supabaseUrl = ""
    while ($supabaseUrl -notmatch "^https://.+\.supabase\.co$") {
        $supabaseUrl = (Read-Host "  SUPABASE_URL").Trim()
        if ($supabaseUrl -notmatch "^https://.+\.supabase\.co$") {
            Write-Warn "Formato invalido. Esperado: https://xxxx.supabase.co"
        }
    }

    $supabaseAnonKey = ""
    while ($supabaseAnonKey.Length -lt 20) {
        $supabaseAnonKey = (Read-Host "  SUPABASE_ANON_KEY").Trim()
        if ($supabaseAnonKey.Length -lt 20) {
            Write-Warn "Chave muito curta. Verifique e tente novamente."
        }
    }

    # Railway removido em 2026-10-03: trocar a URL quando a API voltar a ter deploy.
    $envContent = @"
API_BASE_URL=https://lcf-production.up.railway.app
SUPABASE_URL=$supabaseUrl
SUPABASE_ANON_KEY=$supabaseAnonKey
"@
    $envContent | Out-File -FilePath $envFile -Encoding utf8 -NoNewline
    Write-Ok "Credenciais salvas em $envFile"
}

# ── 4. Dependencias Flutter ───────────────────────────────────
Write-Step "Instalando dependencias Flutter (flutter pub get)"

Set-Location $appPath
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Fail "flutter pub get falhou. Verifique a conexao e tente novamente."
    exit 1
}
Write-Ok "Dependencias instaladas"

# ── Pronto ────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ================================================" -ForegroundColor Green
Write-Host "   Setup concluido!" -ForegroundColor Green
Write-Host "  ================================================" -ForegroundColor Green
Write-Host ""
if (-not $hasDevice) {
    Write-Host "  PROXIMO PASSO:" -ForegroundColor Yellow
    Write-Host "  Inicie um emulador Android no Android Studio" -ForegroundColor Yellow
    Write-Host "  (Tools > Device Manager > selecione e clique no play)" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "  Para rodar o app:" -ForegroundColor White
Write-Host "    .\scripts\run.ps1" -ForegroundColor Cyan
Write-Host ""
