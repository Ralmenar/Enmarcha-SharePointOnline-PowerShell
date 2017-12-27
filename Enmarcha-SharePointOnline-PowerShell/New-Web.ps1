#
# New_Web.ps1
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
	[System.Management.Automation.PSCredential]$credentials 
)
Process
{
	$ctx = Get-PnPContext
	[xml]$manifest = Get-Content "$Path\manifest.xml"
	$url = "$UrlWebApplication/$($manifest.Site.RelativeUrl)"
	Write-Host -ForegroundColor Green "Creando subsitio $url"
	$urlBase= $tenant + $UrlWebApplication 
	
	Connect-PnPOnline -Url $urlBase -Credentials $credentials

	$web= Get-PnPweb -Identity $url -ErrorAction SilentlyContinue
	if ($web -eq $null)
	{	
		New-PnPWeb  -Title $manifest.Site.Name -Url $manifest.Site.RelativeUrl -Description $manifest.Site.Description -Template $manifest.Site.Template   
		Write-Host -ForegroundColor Green "Sitio $url Creado"
	}
	else
	{
		Write-Host -ForegroundColor Yellow "El sitio  $url ya Existe!!"
	}

	Write-Host "Ruta a analizar" $Path
	$urlSource =$tenant + $UrlWebApplication + "/"+$manifest.Site.RelativeUrl	

	Connect-PnPOnline -Url $urlSource -Credentials $credentials
	
	Get-ChildItem -Path $Path -Filter "PAGE" | % {
                $list = & "$currentPath\New-Page.ps1" -Path $_.FullName -tenant $tenant -UrlWebApplication $UrlWebApplication 
            }
	if ($manifest.Site.WelcomePage.Url -ne $null)
	{
			
		Write-Host -ForegroundColor Yellow "Estableciendo pagina de inicio en el site" $urlSource 
		
		Set-PnPHomePage -RootFolderRelativeUrl $manifest.Site.WelcomePage.Url
		Write-Host -ForegroundColor Green "Ok"	
		Set-PnPContext -Context $ctx # switch back to site A
	}	
}