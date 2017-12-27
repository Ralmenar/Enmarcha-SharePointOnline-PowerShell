#
# New_Page.ps1
#
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Path,	
    [Parameter(Mandatory=$true)]
    [string]$tenant,
	[Parameter(Mandatory=$true)]
    [string]$UrlWebApplication
)
Process
{
	 Write-Host -ForegroundColor Yellow "Creando la Pagina $Path"
	$url = "$tenant$($UrlWebApplication)"
	
	#	$ctx = Get-PnPContext
    $currentPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
	Get-ChildItem -Path $Path  | % {
			$strFileName=$_.FullName
		[xml]$manifest = Get-Content "$strFileName"
		Write-Host $manifest.Page.Url
		$urlsite= "$url$($manifest.Page.Url)"
		Write-Host $urlsite
		#Connect-PnPOnline -Url $urlsite	
		Write-Host "Me acabo de conectar al sitio .." $urlsite
				Add-PnPModernPage -NamePage $manifest.Page.Name
				Write-Host -ForegroundColor Green "Pagina Creada Correctamente"		
				$manifest.Page.Webparts.Webpart | % {
					Add-PnPWebPartToModernPage -ServerRelativePageUrl $manifest.Page.Name -NameWebPart $_.name -ZoneIndex $_.zone
				}			
	}
	#Set-PnPContext -Context $ctx # switch back to site A
}