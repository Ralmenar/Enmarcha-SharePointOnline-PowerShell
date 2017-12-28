Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path,	
    [Parameter(Mandatory = $true)]
    [string]$tenant,
    [Parameter(Mandatory = $true)]
    [string]$UrlWebApplication
)
Process {
    Get-ChildItem -Path $Path  | % {
        $strFileName = $_.FullName
        [xml]$manifest = Get-Content "$strFileName"

        if ($manifest.Page.RemoveAtFirst -ne $null -and $manifest.Page.RemoveAtFirst.ToLower() -eq "true") {
            Remove-PnPClientSidePage $manifest.Page.Name -Force
            Write-Host -ForegroundColor Green "Pagina '"$manifest.Page.Name"' borrada correctamente"
        }

        $commentsEnabled = $false
        if ($manifest.Page.CommentsEnabled -ne $null -and $manifest.Page.CommentsEnabled.ToLower() -eq "true") {
            $commentsEnabled = $true
        }
        Add-PnPClientSidePage -Name $manifest.Page.Name -CommentsEnabled $commentsEnabled
        Write-Host -ForegroundColor Green "Pagina '"$manifest.Page.Name"' creada correctamente"
        
        $page = Get-PnPClientSidePage $manifest.Page.Name

        if ($page.Controls.Count -eq 0) {
            Write-Host -ForegroundColor Green "Agregando Webparts a la página"
            $manifest.Page.Webparts.Webpart | % {
                Add-PnPClientSideWebPart -Page $manifest.Page.Name -DefaultWebPartType $_.Name
            }		
        }
    }
}