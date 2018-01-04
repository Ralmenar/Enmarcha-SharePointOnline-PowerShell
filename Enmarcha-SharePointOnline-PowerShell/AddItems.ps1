Param(
    [Parameter(Mandatory = $true)]
    [string]$tenant,
    [Parameter(Mandatory = $true)]
    [string]$UrlWebApplication,
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$credentials,
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$CurrentPath	
)
Process {
    [xml]$manifest = Get-Content "$Path\ITEMS\manifest.xml"
    if ($manifest.Items.Add -ne $null) {
        $manifest.Items.Add | % {
            Write-Host -ForegroundColor Blue $_.File
                
            $pathJson = "$Path\$(($_.File))\item.json"
            Write-Host -ForegroundColor Blue $pathJson
            $url = "$tenant$($UrlWebApplication)"
            $urlSite = "$url/$($_.siteUrl)"
            Write-Host $urlSite
            $items = & "$currentPath\New-Item.ps1" -Path $pathJson -siteUrl $urlSite -ListName $_.listName  -credentials $credentials 
            Write-Host -ForegroundColor DarkGreen "Finalizado items "
        }
    }
}

