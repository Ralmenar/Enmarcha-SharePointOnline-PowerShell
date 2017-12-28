Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$tenant,
    [Parameter(Mandatory = $true)]
    [string]$UrlWebApplication,
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$credentials 
)
Process {
    $ctx = Get-PnPContext
    [xml]$manifest = Get-Content "$Path\manifest.xml"
    $url = "$UrlWebApplication/$($manifest.Site.RelativeUrl)"
    Write-Host -ForegroundColor Green "Creando subsitio $url"
    $urlBase = $tenant + $UrlWebApplication 
	
    Connect-PnPOnline -Url $urlBase -Credentials $credentials

    $web = Get-PnPweb -Identity $url -ErrorAction SilentlyContinue
    if ($web -eq $null) {	
        New-PnPWeb  -Title $manifest.Site.Name -Url $manifest.Site.RelativeUrl -Description $manifest.Site.Description -Template $manifest.Site.Template   
        Write-Host -ForegroundColor Green "Sitio $url Creado"
    }
    else {
        Write-Host -ForegroundColor Yellow "El sitio  $url ya Existe!!"
    }

    Write-Host "Ruta a analizar" $Path
    $urlSource = $tenant + $UrlWebApplication + "/" + $manifest.Site.RelativeUrl	

    Connect-PnPOnline -Url $urlSource -Credentials $credentials
	
    if ($manifest.Site.WelcomePage.Url -ne $null) {			
        Write-Host -ForegroundColor Yellow "Estableciendo pagina de inicio en el site" $manifest.Site.WelcomePage.Url 
		
        Set-PnPHomePage -RootFolderRelativeUrl $manifest.Site.WelcomePage.Url
        Write-Host -ForegroundColor Green "Ok"	
        Set-PnPContext -Context $ctx # switch back to site A
    }	
    if ($manifest.Site.Navigation -ne $null) {
        Write-Host -ForegroundColor Yellow "Modificando la navegación"
        $manifest.Site.Navigation.Add | % {
            Remove-PnPNavigationNode -Title $_.Title -Location $_.Location -Force
            if ($_.IsExternal -ne $null -and $_.IsExternal.ToLower() -eq "true") {
                Add-PnPNavigationNode -Location $_.Location -Title $_.Title -External -Url ($UrlWebApplication+$_.Url)
            } else {
                Add-PnPNavigationNode -Location $_.Location -Title $_.Title -Url ($UrlWebApplication+$_.Url)
            }
        }
        $manifest.Site.Navigation.Remove | % {
            Remove-PnPNavigationNode -Title $_.Title -Location $_.Location -Force
        }

        Write-Host -ForegroundColor Green "Navegación actualizada"
    }
    if ($manifest.Site.Theme.Url -ne $null) {
		
        $url = [string]::Concat($UrlWebApplication.Trim(), $manifest.Site.Theme.Url.Trim())
        Write-Host  "Aplicando el Tema establecido " $url
        Set-PnPTheme -ColorPaletteUrl $url -ResetSubwebsToInherit
        Write-Host -ForegroundColor Green "Ok"
    }	
    if ($manifest.Site.IconUrl -ne $null) {			
        $urlIcon = $UrlWebApplication + $manifest.Site.IconUrl
        Write-Host  "Estableciendo el icono del sitio " $urlIcon
        Set-PnPSiteLogo -RootFolderRelativeUrl $manifest.Site.IconUrl.Trim()
        Write-Host -ForegroundColor Green "Ok"
    }
}