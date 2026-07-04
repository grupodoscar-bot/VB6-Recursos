# generar-manifiesto.ps1
# Regenera comun/manifiesto.txt (control de versiones por HASH) y lo sube.
# El comun (DescargarRecursos) baja este manifiesto y descarga solo lo cambiado.
# Ejecutar cuando se anada/actualice un recurso distribuible.
$ErrorActionPreference = 'Stop'

$repo       = 'Z:\VB6-Recursos'
$manifiesto = Join-Path $repo 'comun\manifiesto.txt'

# --- Recursos bajo control de version (anadir aqui los que queramos distribuir) ---
#   ruta      : ruta dentro del repo (y de la URL raw)
#   destino   : APP  (App.Path del programa)  |  APP\sub  (subcarpeta)
#   programas : *  (todos)  |  lista  bar,gestion,peluqueria,taller,tpv,carpintero,cristaleria
$recursos = @(
    @{ ruta = 'comun/reparaBasedatos.exe'; destino = 'APP'; programas = '*' }
    # @{ ruta = 'comun/recursos/verifactu.bmp'; destino = 'APP'; programas = '*' }
    # @{ ruta = 'comun/otro.exe';               destino = 'APP'; programas = 'bar,gestion' }
)

$lineas = @('# Manifiesto de recursos VB6-Recursos (generado por generar-manifiesto.ps1).',
    '# Formato:  hash|rutaRepo|destino|programas   (hash = SHA1 corto del fichero)')

foreach ($r in $recursos) {
    $f = Join-Path $repo ($r.ruta -replace '/', '\')
    if (-not (Test-Path $f)) { Write-Warning "No existe, se omite: $f"; continue }
    $h = (Get-FileHash $f -Algorithm SHA1).Hash.Substring(0, 12).ToLower()
    $lineas += ('{0}|{1}|{2}|{3}' -f $h, $r.ruta, $r.destino, $r.programas)
    Write-Host ("  {0}  {1}" -f $h, $r.ruta)
}

[System.IO.File]::WriteAllText($manifiesto, (($lineas -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Manifiesto -> " + $manifiesto) -ForegroundColor Green

# Subir (y limpiar el version.txt obsoleto del esquema anterior, si existe)
$tok = (Get-Content 'Z:\_buildqueue\token.txt' -Raw).Trim()
git config --global --add safe.directory '*' | Out-Null
Push-Location $repo
$verObsoleto = 'comun/reparaBasedatos.version.txt'
if (Test-Path (Join-Path $repo ($verObsoleto -replace '/', '\'))) { git rm -q $verObsoleto | Out-Null }
git add 'comun/manifiesto.txt'
git commit -m 'manifiesto de recursos actualizado' | Out-Null
$remote = 'https://grupodoscar-bot:' + $tok + '@github.com/grupodoscar-bot/VB6-Recursos.git'
git push $remote HEAD:main
Pop-Location
Write-Host 'LISTO: manifiesto publicado en VB6-Recursos/comun.' -ForegroundColor Green
