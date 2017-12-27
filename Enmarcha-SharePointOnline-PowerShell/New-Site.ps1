#
# New_Site.ps1
#
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Path,
	 [Parameter(Mandatory=$true)]
    [string]$tenant,
    [Parameter(Mandatory=$true)]
    [string]$UrlWebApplication,
    [Parameter(Mandatory=$true)]
    [string]$OwnerAlias,    		
	[Parameter(Mandatory=$true)]  
    [string]$PathConfiguration =  $(Read-Host -Prompt "Path Configuration"),
	[Parameter(Mandatory=$true)]
	[System.Management.Automation.PSCredential]$credentials 
)
Process
{
	[xml]$manifest = Get-Content "$PathConfiguration\manifest.xml"
	$url = "$tenant$($UrlWebApplication)"
	Write-Host $UrlWebApplication
	Write-Host -ForegroundColor Green "Creando la colección de sitios $url"

	Connect-PnPOnline -Url $url -ErrorAction SilentlyContinue -Credentials $credentials

	$result= Get-PnPTenantSite -Url $url  -ErrorAction SilentlyContinue
	if ($result.Url -eq $null)
	{		
		New-PnPTenantSite -Wait -Title $manifest.Site.Name -Url $UrlWebApplication -Description $manifest.Site.Description -Template $manifest.Site.Template -Lcid $manifest.Site.Language -Owner $OwnerAlias -TimeZone 4 
		Write-Host -ForegroundColor Green "Colección de sitios $url Creada"
		Start-Sleep -s 200
		Connect-PnPOnline -Url $url -Credentials $credentials
	}
	else
	{
		Write-Host -ForegroundColor Yellow "La colección de sitios $url ya Existe!!"
	}
	Get-ChildItem -Path $Path -Filter "FILE" | % {
                $list = & "$currentPath\New-File.ps1" -Path $_.FullName 
     }
	Get-ChildItem -Path $Path -Filter "PAGE" | % {
                $list = & "$currentPath\New-Page.ps1" -Path $_.FullName -tenant $tenant -UrlWebApplication $UrlWebApplication 
            }
	if ($manifest.Site.WelcomePage.Url -ne $null)
	{
		Set-PnPHomePage -RootFolderRelativeUrl $manifest.Site.WelcomePage.Url
	}
	if ($manifest.Site.Theme.Url -ne $null)
	{
		
		$url = [string]::Concat($UrlWebApplication.Trim(), $manifest.Site.Theme.Url.Trim())
		Write-Host  "Aplicando el Tema establecido " $url
		Set-PnPTheme -ColorPaletteUrl $url -ResetSubwebsToInherit
		Write-Host -ForegroundColor Green "Ok"
	}	
	if ($manifest.Site.IconUrl -ne $null)
	{			
		$urlIcon=$UrlWebApplication+$manifest.Site.IconUrl
		Write-Host  "Estableciendo el icono del sitio " $urlIcon
		Set-PnPSiteLogo -RootFolderRelativeUrl $manifest.Site.IconUrl.Trim()
		Write-Host -ForegroundColor Green "Ok"
	}
}