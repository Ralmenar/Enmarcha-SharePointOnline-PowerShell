#
# New_Taxonomy.ps1
#
Param(
	[Parameter(Mandatory=$true)]
    [string]$Path
)
Process
{
	Get-ChildItem -Path $Path | % {
		Write-Host "Procesando la taxonomia del fichero" $_.FullName -ForegroundColor Blue
		Import-PnPTaxonomy -Path $_.FullName -Delimiter "|" 
		Write-Host "OK" -ForegroundColor Green
	}
}