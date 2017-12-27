Param(
	 [Parameter(Mandatory=$true)]
    [string]$tenant,
    [Parameter(Mandatory=$true)]
    [string]$UrlWebApplication,
		[Parameter(Mandatory=$true)]
	[System.Management.Automation.PSCredential]$credentials,
	[Parameter(Mandatory=$true)]
	[string]$Path	
)

Process{
		$csvs = Import-CSV $Path\Lookup.csv -Delimiter ";"
		$url = "$tenant$($UrlWebApplication)"
		foreach($csv in $csvs){
		try{
			$urlSite="$url/$($csv.siteUrl)"
			Write-Host $urlSite
			Connect-PnPOnline -Url $urlSite -ErrorAction SilentlyContinue -Credentials $credentials
			$clientContext = Get-PnPContext			
			$web = $clientContext.Web
            $webFields = $web.Fields
			$clientContext.Load($web)
			$clientContext.Load($webFields)
			$clientContext.ExecuteQuery()

            $castToMethodGeneric = [Microsoft.SharePoint.Client.ClientContext].GetMethod("CastTo")
            $castToMethodLookup = $castToMethodGeneric.MakeGenericMethod([Microsoft.SharePoint.Client.FieldLookup])

			$webList = $web.Lists
			$clientContext.Load($webList)
			$clientContext.ExecuteQuery()

			$customList = $webList.GetByTitle($csv.sourceListName)

			$fields = $customList.Fields;
			$customList.Update()
			$clientContext.Load($customList)
			$clientContext.Load($fields)
			$clientContext.ExecuteQuery()

			$parentList = $webList.GetByTitle($csv.parentListName)
			$parentList.Update()
			$clientContext.Load($parentList)
			$clientContext.ExecuteQuery()
			$idParentList = $parentList.Id

			$exists = $false;

			foreach ($field in $fields) 
			{
				if($field.Title -eq $csv.DisplayName) 
				{
					$exists = $true
				}
			}

			$lookupSchema = "<Field Type='Lookup'                                
							DisplayName = '"+$csv.LookupField+"'
                            Required = '"+$csv.Required+"' 
							EnforceUniqueValues = 'FALSE'
                            List = '{$idParentList}'
							ShowField = '" +$csv.DisplayName+"' 
							UnlimitedLengthInDocumentLibrary = 'FALSE' 
							RelationshipDeleteBehavior = 'None' 
							StaticName = '"+$csv.LookupField+"' 
							Name = '"+$csv.LookupField+ "' />"

			if ($exists -eq $false)
			{
                $option = [Microsoft.SharePoint.Client.AddFieldOptions]::AddToAllContentTypes

                $newLookupField = $fields.AddFieldAsXml($lookupSchema, $true, $option)
				$customList.Update()
                $clientContext.ExecuteQuery()
			}

			} catch{
		Write-Host -ForegroundColor Red "Ha ocurrido un error al crear la columna Lookup con el nombre: " $csv.DisplayName + $_.Exception.Message
			} 	
		}
}