Param
(
    [Parameter(Mandatory=$true)]
    [string]$Path,
	[Parameter(Mandatory=$true)]
    [string]$urlWebapplication,
	[Parameter(Mandatory=$true)]
	[string]$tenant,
	[Parameter(Mandatory=$true)]
	[System.Management.Automation.PSCredential]$credentials 
)
Process
{
	Import-Module "$currentPath\EnmarchaFunctions.psm1" -PassThru -Force -DisableNameChecking | Out-Null
    Write-Host -ForegroundColor Yellow "Creando la lista $Path"
	
	$ctx = Get-PnPContext
    $currentPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

	$strFileName="$Path\manifest.xml"
	If (Test-Path $strFileName) {

		[xml]$manifest = Get-Content "$Path\manifest.xml"
		$url = "$tenant$($UrlWebApplication)"
		$urlsite= "$url$($manifest.List.Url)"
		Write-Host -ForegroundColor DarkMagenta $urlsite

		Connect-PnPOnline -Url $urlsite -Credentials $credentials
		
		$existingList = Get-PnpList | Where-Object{ $_.Title -eq $manifest.List.Name} 
		if ($existingList.Title -ne $null)
		{
		Write-Host -ForegroundColor Yellow  "La lista '"$manifest.List.Name"' ya existe"       
			Remove-PnPContentTypeFromList -List $manifest.List.Name -ContentType "Document"
		}
		else
		{
		$list= New-PnPList -Title $manifest.List.Name -Template DocumentLibrary  -EnableContentTypes  -OnQuickLaunch 
	
		if($manifest.List.ContentTypes -ne $null)
		{
			$manifest.List.ContentTypes.ContentType | % {
				Write-Host -ForegroundColor Green "Agregando el Content Type "$_.Name" a la lista $Path"
				Add-PnPContentTypeToList -List $manifest.List.Name  -ContentType $_.Name
				}
			Remove-PnPContentTypeFromList -List $manifest.List.Name -ContentType "Document"
		}
			
		if($manifest.List.DocumentSets -ne $null)
		{
				$contador=1;
			$manifest.List.DocumentSets.ContentTypes.ContentType | % {			   
				if ($contador -eq 1){
					Write-Host -ForegroundColor Green "Creo el Document Set $manifest.List.DocumentSets.name"
					Write-Host $manifest.List.Name
					Write-Host $_.name
					Write-Host $manifest.List.DocumentSets.Name
					Add-PnPDocumentSet -List $manifest.List.Name -ContentType $_.Name -Name $manifest.List.DocumentSets.Name -ErrorAction SilentlyContinue
					$contador=2;
				}			   
				else
				{
					Write-Host -ForegroundColor Green "Agregando el Content Type {$_.Name} al DocumentSet $Path"
					Add-PnPContentTypeToDocumentSet -ContentType $_.Name -DocumentSet $manifest.List.DocumentSets.Name -ErrorAction SilentlyContinue
					}
				}
		}
			}
			if($manifest.List.Views -ne $null)
			{
				$manifest.List.Views.View | % {
					$query=$_.Query 
					$query=$query.Replace("<Query>","")
					$query=$query.Replace("</Query>","")
					$field=$_.Fields -split ","
					$resultField = New-Object string[] $field.Count
					For($i=0; $i -le $field.Count-1; $i++)
					{					 
						$resultField[$i]=$field[$i]
					}

					if ($_.Default -eq "true")
					{
						Write-Host "Add-PnPView -List" $manifest.List.Name "-Title " $_.Name "-Query " $query " -SetAsDefault  -Fields " $resultField "-Paged "
						Add-PnPView -List $manifest.List.Name -Title $_.Name -Query $query -Fields $resultField  -Paged -SetAsDefault
						
					}
					else
					{
						Write-Host "Add-PnPView -List" $manifest.List.Name "-Title " $_.Name "-Query " $query " -Fields " $resultField "-Paged "
						Add-PnPView -List $manifest.List.Name -Title $_.Name -Query $query  -Fields $_.Fields -Paged
					}
				}
			}
			if($manifest.List.DefaultValues -ne $null)
			{
				$manifest.List.DefaultValues.DefaultValue | % {
					$taxonomyItem = $_.Value -split ";"
					Write-Host $_.Field " Count" $taxonomyItem.Count
					if ($taxonomyItem.Count -gt 1 )
					{
						$item = Get-PnPTerm -Identity $taxonomyItem[2] -TermGroup $taxonomyItem[0] -TermSet $taxonomyItem[1]
						Write-Host "Id de la Taxonomia es " $item.Id "-" $item.Name
	
						Write-Host "Set-PnPDefaultColumnValues -List" $manifest.List.Name " -Field " $_.Field " -Value " $item.Id -ForegroundColor Green
						Set-PnPDefaultColumnValues -List $manifest.List.Name -Field $_.Field -Value $item.Id
					}
					else
					{
						Write-Host "Set-PnPDefaultColumnValues -List" $manifest.List.Name " -Field " $_.Field " -Value " $_.Value -ForegroundColor Green
						Set-PnPDefaultColumnValues -List $manifest.List.Name -Field $_.Field -Value $_.Value
					}
				}
			}
	}
	Set-PnPContext -Context $ctx # switch back to site A
}