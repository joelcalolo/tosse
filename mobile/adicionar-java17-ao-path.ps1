# Script para adicionar Java 17 ao PATH do sistema
# Execute este script como Administrador

$java17Path = "C:\Program Files\Java\jdk-17\bin"

# Verificar se Java 17 existe
if (-not (Test-Path $java17Path)) {
    Write-Host "Erro: Java 17 não encontrado em $java17Path" -ForegroundColor Red
    exit 1
}

# Verificar se já está no PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -like "*$java17Path*") {
    Write-Host "Java 17 já está no PATH do sistema." -ForegroundColor Yellow
    exit 0
}

# Adicionar ao PATH do sistema
try {
    $newPath = $currentPath + ";$java17Path"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "Java 17 adicionado ao PATH do sistema com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANTE: Feche e reabra o terminal para que as mudanças tenham efeito." -ForegroundColor Yellow
    Write-Host "Ou execute: refreshenv (se tiver Chocolatey instalado)" -ForegroundColor Yellow
} catch {
    Write-Host "Erro ao adicionar ao PATH: $_" -ForegroundColor Red
    Write-Host "Certifique-se de executar este script como Administrador!" -ForegroundColor Red
    exit 1
}


