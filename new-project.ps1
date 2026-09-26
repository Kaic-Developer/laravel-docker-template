param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9_-]+$')]
    [string]$Name
)

$ErrorActionPreference = "Stop"

# ============================================================
# Laravel Docker Template
# Project Generator
#
# Author: Kaic Leonardo
# GitHub: https://github.com/Kaic-Developer
# LinkedIn: https://www.linkedin.com/in/kaic-leonardo-087347345/
# ============================================================

$TemplateDirectory = $PSScriptRoot

# Por padrão, novos projetos serão criados em:
# Projetos/Estudo/<nome-do-projeto>
$ProjectsDirectory = Join-Path (Split-Path $TemplateDirectory -Parent) "..\Estudo"
$ProjectsDirectory = [System.IO.Path]::GetFullPath($ProjectsDirectory)

$ProjectDirectory = Join-Path $ProjectsDirectory $Name


# ============================================================
# FUNÇÕES
# ============================================================

function Write-Step {
    param([string]$Message)

    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}


function Write-Success {
    param([string]$Message)

    Write-Host "[OK] $Message" -ForegroundColor Green
}


function Write-Failure {
    param([string]$Message)

    Write-Host "[ERRO] $Message" -ForegroundColor Red
}


function Test-PortAvailable {
    param([int]$Port)

    try {
        $connection = Get-NetTCPConnection `
            -LocalPort $Port `
            -State Listen `
            -ErrorAction SilentlyContinue

        return ($null -eq $connection)
    }
    catch {
        return $true
    }
}


function Get-AvailablePort {
    param([int]$StartPort)

    $port = $StartPort

    while (-not (Test-PortAvailable -Port $port)) {
        $port++

        if ($port -gt 65535) {
            throw "Nenhuma porta disponível encontrada."
        }
    }

    return $port
}


function Invoke-Docker {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & docker @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Docker retornou erro ao executar: docker $($Arguments -join ' ')"
    }
}


# ============================================================
# CABEÇALHO
# ============================================================

Clear-Host

Write-Host ""
Write-Host "====================================================" -ForegroundColor DarkCyan
Write-Host "        LARAVEL DOCKER PROJECT GENERATOR" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "Projeto: $Name"
Write-Host "Autor:   Kaic Leonardo"
Write-Host ""


try {

    # ========================================================
    # 1. VERIFICAR DOCKER
    # ========================================================

    Write-Step "Verificando Docker..."

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker não foi encontrado no sistema."
    }

    docker info *> $null

    if ($LASTEXITCODE -ne 0) {
        throw "Docker Desktop está instalado, mas o Docker Engine não está rodando."
    }

    Write-Success "Docker está funcionando."


    # ========================================================
    # 2. VERIFICAR DIRETÓRIO DO PROJETO
    # ========================================================

    Write-Step "Preparando diretório..."

    if (Test-Path $ProjectDirectory) {
        throw "A pasta '$ProjectDirectory' já existe."
    }

    if (-not (Test-Path $ProjectsDirectory)) {
        New-Item `
            -ItemType Directory `
            -Path $ProjectsDirectory `
            -Force | Out-Null
    }

    New-Item `
        -ItemType Directory `
        -Path $ProjectDirectory | Out-Null

    Write-Success "Diretório criado:"
    Write-Host "     $ProjectDirectory"


    # ========================================================
    # 3. COPIAR INFRAESTRUTURA DO TEMPLATE
    # ========================================================

    Write-Step "Copiando infraestrutura Docker..."

    Copy-Item `
        (Join-Path $TemplateDirectory "Dockerfile") `
        $ProjectDirectory

    Copy-Item `
        (Join-Path $TemplateDirectory "docker-compose.yml") `
        $ProjectDirectory

    Copy-Item `
        (Join-Path $TemplateDirectory "docker") `
        $ProjectDirectory `
        -Recurse

    Write-Success "Infraestrutura Docker copiada."


    # ========================================================
    # 4. DESCOBRIR PORTAS DISPONÍVEIS
    # ========================================================

    Write-Step "Procurando portas disponíveis..."

    $AppPort = Get-AvailablePort 8000
    $MailpitWebPort = Get-AvailablePort 8025
    $MailpitSmtpPort = Get-AvailablePort 1025
    $MysqlPort = Get-AvailablePort 3306

    Write-Success "Portas selecionadas."

    Write-Host ""
    Write-Host "Laravel:      $AppPort"
    Write-Host "Mailpit Web:  $MailpitWebPort"
    Write-Host "Mailpit SMTP: $MailpitSmtpPort"
    Write-Host "MySQL:        $MysqlPort"


    # ========================================================
    # 5. CRIAR .ENV DO DOCKER
    # ========================================================

    Write-Step "Criando configuração Docker..."

    $DockerEnvironment = @"
COMPOSE_PROJECT_NAME=$Name

APP_PORT=$AppPort

DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=laravel
DB_ROOT_PASSWORD=root
DB_PORT_FORWARD=$MysqlPort

MAILPIT_SMTP_PORT=$MailpitSmtpPort
MAILPIT_WEB_PORT=$MailpitWebPort
"@

    Set-Content `
        -Path (Join-Path $ProjectDirectory ".env") `
        -Value $DockerEnvironment `
        -Encoding UTF8

    Write-Success "Configuração Docker criada."


    # ========================================================
    # 6. IR PARA O NOVO PROJETO
    # ========================================================

    Set-Location $ProjectDirectory


    # ========================================================
    # 7. BUILD DA IMAGEM PHP
    # ========================================================

    Write-Step "Construindo imagem PHP..."

    Invoke-Docker compose build php

    Write-Success "Imagem PHP construída."


    # ========================================================
    # 8. CRIAR LARAVEL
    # ========================================================

    Write-Step "Criando novo projeto Laravel..."

    Invoke-Docker compose run --rm php `
        composer create-project laravel/laravel app

    Write-Success "Laravel instalado."


    # ========================================================
    # 9. CONFIGURAR .ENV DO LARAVEL
    # ========================================================

    Write-Step "Configurando Laravel..."

    $LaravelEnvPath = Join-Path $ProjectDirectory "app\.env"

    if (-not (Test-Path $LaravelEnvPath)) {
        throw "Arquivo .env do Laravel não foi encontrado."
    }

    $LaravelEnv = Get-Content $LaravelEnvPath -Raw

    # URL
    $LaravelEnv = $LaravelEnv `
        -replace 'APP_URL=.*', "APP_URL=http://localhost:$AppPort"


    # Banco
    $LaravelEnv = $LaravelEnv `
        -replace 'DB_CONNECTION=.*', 'DB_CONNECTION=mysql'

    $LaravelEnv = $LaravelEnv `
        -replace '# DB_HOST=.*', 'DB_HOST=mysql'

    $LaravelEnv = $LaravelEnv `
        -replace '# DB_PORT=.*', 'DB_PORT=3306'

    $LaravelEnv = $LaravelEnv `
        -replace '# DB_DATABASE=.*', 'DB_DATABASE=laravel'

    $LaravelEnv = $LaravelEnv `
        -replace '# DB_USERNAME=.*', 'DB_USERNAME=laravel'

    $LaravelEnv = $LaravelEnv `
        -replace '# DB_PASSWORD=.*', 'DB_PASSWORD=laravel'


    # Session / Cache
    $LaravelEnv = $LaravelEnv `
        -replace 'SESSION_DRIVER=.*', 'SESSION_DRIVER=file'

    $LaravelEnv = $LaravelEnv `
        -replace 'CACHE_STORE=.*', 'CACHE_STORE=file'


    # Mailpit
    $LaravelEnv = $LaravelEnv `
        -replace 'MAIL_MAILER=.*', 'MAIL_MAILER=smtp'

    $LaravelEnv = $LaravelEnv `
        -replace 'MAIL_HOST=.*', 'MAIL_HOST=mailpit'

    $LaravelEnv = $LaravelEnv `
        -replace 'MAIL_PORT=.*', 'MAIL_PORT=1025'

    Set-Content `
        -Path $LaravelEnvPath `
        -Value $LaravelEnv `
        -Encoding UTF8

    Write-Success "Laravel configurado."


    # ========================================================
    # 10. SUBIR CONTAINERS
    # ========================================================

    Write-Step "Iniciando containers..."

    Invoke-Docker compose up -d

    Write-Success "Containers iniciados."


    # ========================================================
    # 11. AGUARDAR MYSQL
    # ========================================================

    Write-Step "Aguardando MySQL..."

    $MaxAttempts = 30
    $Attempt = 0
    $MysqlReady = $false

    while (($Attempt -lt $MaxAttempts) -and (-not $MysqlReady)) {

        $Attempt++

        docker compose exec -T mysql `
            mysqladmin ping `
            -h localhost `
            -proot *> $null

        if ($LASTEXITCODE -eq 0) {

            $MysqlReady = $true

        }
        else {

            Start-Sleep -Seconds 2

        }
    }

    if (-not $MysqlReady) {
        throw "MySQL não ficou disponível dentro do tempo esperado."
    }

    Write-Success "MySQL está pronto."


    # ========================================================
    # 12. LIMPAR CONFIGURAÇÕES
    # ========================================================

    Write-Step "Limpando cache do Laravel..."

    Invoke-Docker compose exec -T php `
        php artisan optimize:clear

    Write-Success "Cache limpo."


    # ========================================================
    # 13. MIGRATIONS
    # ========================================================

    Write-Step "Executando migrations..."

    Invoke-Docker compose exec -T php `
        php artisan migrate --force

    Write-Success "Migrations executadas."


    # ========================================================
    # 14. STORAGE LINK
    # ========================================================

    Write-Step "Criando storage link..."

    docker compose exec -T php `
        php artisan storage:link *> $null

    Write-Success "Storage configurado."


    # ========================================================
    # FINAL
    # ========================================================

    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host "             PROJETO CRIADO COM SUCESSO" -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "Projeto:"
    Write-Host "  $ProjectDirectory" -ForegroundColor White

    Write-Host ""
    Write-Host "Laravel:"
    Write-Host "  http://localhost:$AppPort" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Mailpit:"
    Write-Host "  http://localhost:$MailpitWebPort" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "MySQL:"
    Write-Host "  localhost:$MysqlPort" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "Comandos úteis:"
    Write-Host ""

    Write-Host "  docker compose ps"
    Write-Host "  docker compose logs -f"
    Write-Host "  docker compose down"
    Write-Host "  docker compose up -d"

    Write-Host ""
    Write-Host "Artisan:"
    Write-Host ""

    Write-Host "  docker compose exec php php artisan migrate"
    Write-Host "  docker compose exec php php artisan tinker"

    Write-Host ""
    Write-Host "===================================================="
    Write-Host ""

}
catch {

    Write-Host ""

    Write-Failure $_.Exception.Message

    Write-Host ""
    Write-Host "O projeto não pôde ser criado completamente." `
        -ForegroundColor Yellow

    Write-Host ""

    exit 1
}