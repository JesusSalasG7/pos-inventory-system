# Ejecuta la app en un teléfono Android físico (Windows).
#
#   scripts\run_device.ps1                USB: redirige el puerto con adb reverse
#   scripts\run_device.ps1 192.168.1.50   Wi-Fi: usa la IP del PC en la red local
#
# Los argumentos a partir del segundo se pasan tal cual a `flutter run`.
param(
    [string]$LanIp = "",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
$Port = if ($env:API_PORT) { $env:API_PORT } else { "8000" }

if ($LanIp) {
    $ApiBaseUrl = "http://${LanIp}:${Port}"
    Write-Host "Modo Wi-Fi: el backend debe correr con 'runserver 0.0.0.0:${Port}'"
    Write-Host "y ${LanIp} debe estar en DJANGO_ALLOWED_HOSTS de pos_backend/.env"
} else {
    adb reverse "tcp:${Port}" "tcp:${Port}"
    if ($LASTEXITCODE -ne 0) { throw "adb reverse falló. ¿Está el teléfono conectado y autorizado?" }
    $ApiBaseUrl = "http://localhost:${Port}"
    Write-Host "Modo USB: adb reverse activo en el puerto ${Port}"
}

Write-Host "API_BASE_URL=${ApiBaseUrl}"
flutter run "--dart-define=API_BASE_URL=${ApiBaseUrl}" @FlutterArgs
