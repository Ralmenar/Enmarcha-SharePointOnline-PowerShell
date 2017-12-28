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

        $commentsEnabled = $false
        if ($manifest.Page.CommentsEnabled -ne $null -and $manifest.Page.CommentsEnabled.ToLower() -eq "true") {
            $commentsEnabled = $true
        }
        Add-PnPClientSidePage -Name $manifest.Page.Name -CommentsEnabled $commentsEnabled
        Write-Host -ForegroundColor Green "Pagina '"$manifest.Page.Name"' Creada Correctamente"
        
        $page = Get-PnPClientSidePage $manifest.Page.Name

        if ($page.Controls.Count -eq 0) {
            Write-Host -ForegroundColor Green "Agregando Webparts a la página"
            $manifest.Page.Webparts.Webpart | % {
                Add-PnPClientSideWebPart -Page $manifest.Page.Name -DefaultWebPartType $_.Name
            }		
        }
    }
}