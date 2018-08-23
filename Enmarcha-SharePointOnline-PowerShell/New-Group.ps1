Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path
)
Process {
    [xml]$manifest = Get-Content "$Path\manifest.xml"
	
    if ($manifest.Groups.Group) {
        $manifest.Groups.Group | % {
            Write-Host -ForegroundColor Green "Creando el grupo " $_.Name
            $group = Get-PnPGroup -Identity $_.Name  -ErrorAction SilentlyContinue
            if ($group -eq $null) {		
                New-PnPGroup -Title $_.Name
                Write-Host -ForegroundColor Green "Grupo " $_.Name " Creado"
                $group = Get-PnPGroup -Identity $_.Name -ErrorAction SilentlyContinue
            }
            else {
                Write-Host -ForegroundColor Yellow "El grupo " $_.Name " ya Existe!"
            }

            if ($_.Permissions) {
                Set-PnPGroupPermissions -Identity $group -AddRole $_.Permissions
            }

            ##A�adimos a los usuarios al grupo 
            #if($_.Users -ne $null)
            #   {
            #	$_.Users.User | % {
            #		Write-Host -ForegroundColor DarkCyan "Agregamos el usuario $manifest.Group.Name al  Grupo $manifest.Group.Name "
            #		Add-PnPUserToGroup -LoginName $_.mail -Identity $_,Name 
            #		Write-Host -ForegroundColor Green "Ok"
            #	}
            #    }
        }
    }

}