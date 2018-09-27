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

    Get-ChildItem -Path $Path  | % {
        $strFileName = $_.FullName
        [xml]$manifest = Get-Content "$strFileName"

        $url = ($tenant+$UrlWebApplication+$manifest.Page.WebRelativeUrl)
        Connect-PnPOnline -Url $url -Credentials $credentials 

        if ($manifest.Page.RemoveAtFirst -ne $null -and $manifest.Page.RemoveAtFirst.ToLower() -eq "true") {
            Remove-PnPClientSidePage $manifest.Page.Name -Force
            Write-Host -ForegroundColor Green "Pagina '"$manifest.Page.Name"' borrada correctamente"
        }

        if ($manifest.Page.CommentsEnabled -ne $null -and $manifest.Page.CommentsEnabled.ToLower() -eq "true") {
            Add-PnPClientSidePage -Name $manifest.Page.Name -CommentsEnabled
        }
        else {
            Add-PnPClientSidePage -Name $manifest.Page.Name
        }
        Write-Host -ForegroundColor Green "Pagina '"$manifest.Page.Name"' creada correctamente"
        
        $page = Get-PnPClientSidePage $manifest.Page.Name

        if ($page.Controls.Count -eq 0) {
            Write-Host -ForegroundColor Green "Agregando Webparts a la página"
            $manifest.Page.Webparts.Webpart | % {
                if($_.Custom.ToLower() -eq "true"){
                    Add-PnPClientSideWebPart -Page $manifest.Page.Name -Component $_.Name
                    Write-Host -ForegroundColor Green "Agregado WebPart '"$_.Name"' a" $manifest.Page.Name
                }else{
                    Add-PnPClientSideWebPart -Page $manifest.Page.Name -DefaultWebPartType $_.Name
                }
            }		
        }
    }

    Set-PnPContext -Context $ctx # switch back to site A
}