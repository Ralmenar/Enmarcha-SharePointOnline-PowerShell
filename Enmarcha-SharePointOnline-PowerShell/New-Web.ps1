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

    if ($manifest.Site.WebFeatures -ne $null) {
        if ($manifest.Site.WebFeatures.Add -ne $null) {
            $manifest.Site.WebFeatures.Add | % {
                Write-Host -ForegroundColor Yellow "Activando característica "$_.Id
                Enable-PnPFeature -Identity $_.Id -Scope Web -Force
                Write-Host -ForegroundColor Green "Ok"
            }
        }
        if ($manifest.Site.WebFeatures.Remove -ne $null) {
            $manifest.Site.WebFeatures.Remove | % {
                Write-Host -ForegroundColor Yellow "Desactivando característica "$_.Id
                Disable-PnPFeature -Identity $_.Id -Scope Web -Force
                Write-Host -ForegroundColor Green "Ok"
            }
        }
    }
	
    if ($manifest.Site.WelcomePage.Url -ne $null) {			
        Write-Host -ForegroundColor Yellow "Estableciendo pagina de inicio en el site" $manifest.Site.WelcomePage.Url 
		
        Set-PnPHomePage -RootFolderRelativeUrl $manifest.Site.WelcomePage.Url
        Write-Host -ForegroundColor Green "Ok"	
        Set-PnPContext -Context $ctx # switch back to site A
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