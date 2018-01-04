Param
(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$siteUrl,	
    [Parameter(Mandatory = $true)]
    [string]$ListName,
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]$credentials 
)
Process {	  
    $strFileName = "$Path"
    Write-Host -ForegroundColor Blue "Introduciendo items en la lista"
    Write-Host -ForegroundColor Blue "$strFileName"
    If (Test-Path $strFileName) {
        Try {
            Connect-PnPOnline -Url $siteUrl -Credentials $credentials
            $ClientContext = Get-PnPContext 
            $manifest = (Get-Content "$strFileName" -Encoding UTF8) | ConvertFrom-Json
            if ($manifest.items -ne $null) {
                Write-Host -ForegroundColor DarkGreen "Hay items"		  
                $manifest.items | % {
                    $List = $ClientContext.Web.Lists.GetByTitle($ListName)
                    $ClientContext.Load($List)
                    $ClientContext.ExecuteQuery()
                    $ListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
                    $NewListItem = $List.AddItem($ListItemCreationInformation)
				
                    $NewListItem[$_[0].Name] = $_[0].Value         
                    $NewListItem.Update()				
                    $ClientContext.ExecuteQuery()                 
                    $idItem = [int]$NewListItem.Id
                    foreach ($property in $_) { 
                        Write-Host -ForegroundColor DarkGreen "Item $($property.Name) $($property.Value) "		
					 
                        if ($property.Type.StartsWith("Taxonomy")) {
                            Write-Host "ID $($idItem)"
                            $List = $ClientContext.Web.Lists.GetByTitle($ListName)
                            $ClientContext.Load($List)
                            $NewListItem = [Microsoft.SharePoint.Client.ListItem] $List.GetItemById($idItem)
                            Write-Host -ForegroundColor DarkGreen "Term $($property.Term)"				  
                            $taxonomyItem = $property.Term -split ";"						 
                            Write-Host -ForegroundColor DarkGreen "TermGroup $($taxonomyItem[0])"		
                            Write-Host -ForegroundColor DarkGreen "TermSet $($taxonomyItem[1])"		
                            Write-Host "Get-PnPTerm -Identity $($property.Value) -TermGroup $($taxonomyItem[0]) -TermSet $($taxonomyItem[1])"
                            $kk1 = $property.Value
                            $item = Get-PnPTerm -Identity $($kk1.Trim()) -TermGroup $taxonomyItem[0].Trim() -TermSet $taxonomyItem[1].Trim()
                            Write-Host "Id de la Taxonomia es " $item.Id "-" $item.Name
                            $NewListItem[$property.Name] = [string]$item.Id 
                            $NewListItem.Update()				
                            $ClientContext.ExecuteQuery()       
                        }
                        else {                         
                            if ($property.Type.StartsWith("MultiTaxonomy")) {
                                Write-Host -ForegroundColor DarkGreen "Multi Term $($property.Term)"		
                                $taxonomyItem = $property.Term -split ";"						 
                                Write-Host -ForegroundColor DarkGreen "TermGroup $($taxonomyItem[0])"		
                                Write-Host -ForegroundColor DarkGreen "TermSet $($taxonomyItem[1])"	
                                $termItem = $property.Value -split ";"
                                $valueMultiTaxonomoy = ""
                                For ($i = 0; $i -lt $termItem.Length; $i++) {
                                    $item = Get-PnPTerm -Identity $($termItem[$i]) -TermGroup $taxonomyItem[0].Trim() -TermSet $taxonomyItem[1].Trim()
                                    Write-Host "Id de la Taxonomia es " $item.Id "-" $item.Name
                                    if ($i -eq 0) {
                                        Write-Host "Valor de i:$($i)"
                                        $valueMultiTaxonomoy = "$($valueMultiTaxonomoy)$([string]$item.Name)|$([string]$item.Id)" 
                                    }
                                    else {
                                        $valueMultiTaxonomoy = "$($valueMultiTaxonomoy);$([string]$item.Name)|$([string]$item.Id)" 
                                    }
                                }
                                $List = $ClientContext.Web.Lists.GetByTitle($ListName)
                                $ClientContext.Load($List)
                                $NewListItem = [Microsoft.SharePoint.Client.ListItem] $List.GetItemById($idItem)
                                Write-Host -ForegroundColor DarkGreen "Valor $($valueMultiTaxonomoy)"
                                $NewListItem[$property.Name] = [string]$valueMultiTaxonomoy
                                $NewListItem.Update()				
                                $ClientContext.ExecuteQuery()         
							
                            }
                            else {
                                $List = $ClientContext.Web.Lists.GetByTitle($ListName)
                                $ClientContext.Load($List)
                                $NewListItem = [Microsoft.SharePoint.Client.ListItem] $List.GetItemById($idItem)
                                $NewListItem[$property.Name] = $property.Value         
                                $NewListItem.Update()				
                                $ClientContext.ExecuteQuery()                 
                            }                     	
                        }					 				    								
                    }
                    # $idItem= $NewListItem.Update()				
                    # $ClientContext.ExecuteQuery()
				
                    Write-Host -ForegroundColor Blue "Insertado con exito"
                }					
            }
        }
        Catch {
            Write-Host -ForegroundColor Red $_.Exception.Message +" "+ $_.Exception.ItemName 
        }
    }
}