# ============================================================
#  Instala las raices Sectigo (R46 + E46) en el almacen de
#  "Entidades de certificacion raiz de confianza" de la MAQUINA.
#  Version silenciosa (para empujar por el actualizador / remoto).
#  Usa .NET X509Store -> funciona incluso en PowerShell 2.0.
#  Requiere permisos de ADMINISTRADOR (almacen LocalMachine\Root).
#  Idempotente: si ya estan, no hace nada.
# ============================================================
$ErrorActionPreference = 'Stop'
$base = Split-Path -Parent $MyInvocation.MyCommand.Path

$raices = @(
    @{ Nombre = 'Sectigo R46'; Fichero = 'SectigoPublicServerAuthenticationRootR46.cer'; Huella = 'AD98F9F3E47D753B65D482B3A45217BB6EF5E438' },
    @{ Nombre = 'Sectigo E46'; Fichero = 'SectigoPublicServerAuthenticationRootE46.cer'; Huella = 'EC8A396C40F02EBC4275D49FAB1C1A5B67BED29A' }
)

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store('Root','LocalMachine')
try {
    $store.Open('ReadWrite')
    foreach ($r in $raices) {
        $ruta = Join-Path $base $r.Fichero
        if (-not (Test-Path $ruta)) { Write-Host ("  [FALTA FICHERO] " + $r.Fichero); continue }

        $ya = $false
        foreach ($c in $store.Certificates) {
            if ($c.Thumbprint -eq $r.Huella) { $ya = $true; break }
        }
        if ($ya) { Write-Host ("  [YA ESTABA] " + $r.Nombre); continue }

        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($ruta)
        if ($cert.Thumbprint -ne $r.Huella) {
            Write-Host ("  [HUELLA NO COINCIDE] " + $r.Nombre + " -> NO instalado (fichero sospechoso)")
            continue
        }
        $store.Add($cert)
        Write-Host ("  [INSTALADA] " + $r.Nombre)
    }
}
finally {
    $store.Close()
}
Write-Host "Hecho."
