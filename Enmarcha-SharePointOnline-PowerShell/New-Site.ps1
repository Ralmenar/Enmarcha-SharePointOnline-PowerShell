Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$tenant,
    [Parameter(Mandatory = $true)]
    [string]$UrlWebApplication,
    [Parameter(Mandatory = $true)]
    [string]$OwnerAlias,    		
    [Parameter(Mandatory = $true)]  
    [string]$PathConfiguration = $(Read-Host -Prompt "Path Configuration"),
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$credentials 
)
Process {
    [xml]$manifest = Get-Content "$PathConfiguration\manifest.xml"
    $url = "$tenant$($UrlWebApplication)"
    Write-Host $UrlWebApplication
    Write-Host -ForegroundColor Green "Creando la colección de sitios $url"

    Connect-PnPOnline -Url $url -ErrorAction SilentlyContinue -Credentials $credentials

    $result = Get-PnPTenantSite -Url $url  -ErrorAction SilentlyContinue
    if ($result.Url -eq $null) {		
        New-PnPTenantSite -Wait -Title $manifest.Site.Name -Url $UrlWebApplication -Description $manifest.Site.Description -Template $manifest.Site.Template -Lcid $manifest.Site.Language -Owner $OwnerAlias -TimeZone 4 
        Write-Host -ForegroundColor Green "Colección de sitios $url Creada"
        Start-Sleep -s 200
        Connect-PnPOnline -Url $url -Credentials $credentials
    }
    else {
        Write-Host -ForegroundColor Yellow "La colección de sitios $url ya Existe!!"
    }
    Get-ChildItem -Path $Path -Filter "FILE" | % {
        $list = & "$currentPath\New-File.ps1" -Path $_.FullName 
    }

    if ($manifest.Site.SiteFeatures -ne $null) {
        if ($manifest.Site.SiteFeatures.Add -ne $null) {
            $manifest.Site.SiteFeatures.Add | % {
                Write-Host -ForegroundColor Yellow "Activando característica "$_.Id
                Enable-PnPFeature -Identity $_.Id -Scope Site -Force
                Write-Host -ForegroundColor Green "Ok"
            }
        }
        if ($manifest.Site.SiteFeatures.Remove -ne $null) {
            $manifest.Site.SiteFeatures.Remove | % {
                Write-Host -ForegroundColor Yellow "Desactivando característica "$_.Id
                Disable-PnPFeature -Identity $_.Id -Scope Site -Force
                Write-Host -ForegroundColor Green "Ok"
            }
        }
    }
	 
    $list = & "$currentPath\New-Web.ps1" -Path $Path -tenant $tenant -UrlWebApplication $UrlWebApplication -Credentials $credentials 
	
}