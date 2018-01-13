Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path
)
Process {
    Write-Host -ForegroundColor Yellow "Subiendo los ficheros de  $Path"
    [xml]$manifest = Get-Content "$Path\manifest.xml" -Encoding UTF8
    if ($manifest.Files.File -ne $null) {
        $manifest.Files.File | % {				
            $origin = $Path.Trim() + "\" + $_.Name.Trim()
            Write-Host -ForegroundColor Yellow "Fichero $Path subiendo desde $origin a "$_.Library 
            if ($_.Publish -ne $null -and $_.Publish.ToLower() -eq "true") {
                Add-PnPFile -Path $origin -Folder $_.Library -Checkout -Publish | Out-Null
            }
            else {
                Add-PnPFile -Path $origin -Folder $_.Library | Out-Null
            }
            Write-Host -ForegroundColor Green "Ok"
        }
    }

}