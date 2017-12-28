Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$urlWebapplication,
    [Parameter(Mandatory = $true)]
    [string]$tenant,
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$credentials 
)
Process {
	  
    $ctx = Get-PnPContext

    $strFileName = "$Path\manifest.xml"
    If (Test-Path $strFileName) {
        [xml]$manifest = Get-Content "$Path\manifest.xml"
        $url = "$tenant$($UrlWebApplication)"

        Connect-PnPOnline -Url $url -Credentials $credentials 
        
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
        
        Set-PnPContext -Context $ctx # switch back to site A
    }
}