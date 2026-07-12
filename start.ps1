# start.ps1 — Lance le backend Next.js + l'app Flutter Haven
# Usage : clic-droit > "Exécuter avec PowerShell"  ou  .\start.ps1 dans un terminal

$root = $PSScriptRoot
$backend = Join-Path $root "haven_backend"
$app     = Join-Path $root "haven_app"

# ─── Vérifications préalables ────────────────────────────────────────────────

if (-not (Test-Path (Join-Path $backend "node_modules"))) {
  Write-Host "[!] node_modules absent. Installation des dépendances backend..." -ForegroundColor Yellow
  Push-Location $backend
  npm install
  Pop-Location
}

# ─── Démarrage du backend dans une nouvelle fenêtre PowerShell ───────────────

Write-Host "[>] Démarrage du backend Next.js (http://localhost:3000)..." -ForegroundColor Cyan

Start-Process powershell -ArgumentList "-NoExit", "-Command", "Set-Location '$backend'; npm run dev"

# Pause pour laisser le temps au backend de s'initialiser avant Flutter
Write-Host "[~] Attente du backend (3s)..." -ForegroundColor DarkGray
Start-Sleep -Seconds 3

# ─── Démarrage de l'app Flutter dans la fenêtre courante ─────────────────────

Write-Host "[>] Démarrage de l'app Flutter..." -ForegroundColor Cyan
Write-Host "    r  = Hot reload    R  = Hot restart" -ForegroundColor DarkGray
Write-Host "    q  = Quitter       d  = Détails appareil" -ForegroundColor DarkGray
Write-Host ""

Set-Location $app
flutter run
