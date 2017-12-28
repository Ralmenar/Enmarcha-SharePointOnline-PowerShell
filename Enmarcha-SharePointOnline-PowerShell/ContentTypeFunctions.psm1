Function New-SiteColumn() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Boolean", "Number", "Text", "LookupMulti", "DateTime", "URL", "Image", "Link", "Note", "HTML", "Calculated", "User", "UserMulti", "Choice", "MultiChoice", "TaxonomyFieldType", "TaxonomyFieldTypeMulti", "SummaryLinks", "MediaFieldType", "Currency")]
        [string]$FieldType,

        [Parameter(Mandatory = $true)]
        [string]$InternalName,

        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [guid]$Id = [System.Guid]::NewGuid(),

        [Parameter(Mandatory = $false)]
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$LocalizedDisplayNames,

        [Parameter(Mandatory = $true)]
        [string]$StaticName,

        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$Hidden = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$Required = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$Sealed = $null,

        [Parameter(Mandatory = $false)]
        [string]$MaxLength = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$ShowInDisplayForm = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$ShowInEditForm = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$ShowInListSettings = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$ShowInNewForm = $null,

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "DateOnly", "DateTime")]
        [string]$DateTimeFormat = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "Image", "Hyperlink")]
        [string]$UrlFormat = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "TRUE", "FALSE")]
        [string]$ImageRichText = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "FullHtml", "ThemeHtml")]
        [string]$ImageRichTextMode = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "TRUE", "FALSE")]
        [string]$LinkRichText = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "FullHtml", "ThemeHtml")]
        [string]$LinkRichTextMode = "",
		
        [Parameter(Mandatory = $false)]
        [ValidateSet("", "TRUE", "FALSE")]
        [string]$NoteRichText = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "FullHtml", "ThemeHtml")]
        [string]$NoteRichTextMode = "",

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$UnlimitedLengthInDocumentLibrary = $null,

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "TRUE", "FALSE")]
        [string]$HtmlRichText = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "FullHtml", "ThemeHtml")]
        [string]$HtmlRichTextMode = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "Boolean", "Integer", "Text", "Note", "DateTime")]   # http://msdn.microsoft.com/en-us/library/microsoft.sharepoint.spfieldtype(v=office.15).aspx
        [string]$CalculatedFormulaValueType = "",

        [Parameter(Mandatory = $false)]
        [string]$CalculatedFormula = "",

        [Parameter(Mandatory = $false)]
        [ValidateSet("", "PeopleOnly", "PeopleAndGroups")]
        [string]$UserSelectionMode = "",

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$UserAllowMultipleValues = $null,

        [Parameter(Mandatory = $false)]
        [string[]]$Choices = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$IsPathRendered = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$IsOpen = $null,

        [Parameter(Mandatory = $false)]
        [string]$TermStoreGroupName,

        [Parameter(Mandatory = $false)]
        [string]$TermSetName,

        [Parameter(Mandatory = $false)]
        [Nullable[bool]]$AllowMultipleValues = $null,

        [Parameter(Mandatory = $false)]
        [string]$CurrencyFormat,

        [Parameter(Mandatory = $false)]
        [string]$DecimalFormat,

        [Parameter(Mandatory = $false)]
        [string]$Description
    )
    Process {
        $existingField = Get-PnpField | Where-Object { $_.InternalName -eq $InternalName} 		
        if ($existingField.Title -ne $null) {
            Write-Host -ForegroundColor Yellow  "El campo '$InternalName' ya existe"
            return
        }
		
        $fieldXml = "<Field Type='$FieldType' ID='$Id' Name='$InternalName' DisplayName='$DisplayName' Description='$Description'></Field>"		
        if ($FieldType -eq "TaxonomyFieldType") {
            $termSetPath = $TermStoreGroupName + "|" + $TermSetName
            Write-Host -ForegroundColor Yellow "El TermsetPath es $termSetPath"
            if ($Required) {
                Write-Host -ForegroundColor Yellow "El Campo es Requerido"
                Add-PnPTaxonomyField -DisplayName $DisplayName -InternalName $InternalName -Group $Group -TermSetPath $termSetPath -Required
            }
            else {
                Write-Host -ForegroundColor Yellow "El Campo NO es Requerido"
                Add-PnPTaxonomyField -DisplayName $DisplayName -InternalName $InternalName -Group $Group -TermSetPath $termSetPath
            }
        }
        else {
            if ($FieldType -eq "Choice" -or $FieldType -eq "MultiChoice") {
                if ($Required) {
                    Write-Host -ForegroundColor Yellow "El Campo  es Requerido"
                    Add-PnPField -DisplayName $DisplayName -InternalName $InternalName -Type $FieldType -Group $Group  -choice $Choices -Required
                }
                else {
                    Write-Host -ForegroundColor Yellow "El Campo NO es Requerido"
                    Add-PnPField -DisplayName $DisplayName -InternalName $InternalName -Type $FieldType -Group $Group  -choice $Choices 
                }
            }

            else {
                if ($FieldType -eq "DateTime") {
                    Write-Host "Creo el campo Fecha"
                    $schema = "<Field ID='" + $Id + "' Type='DateTime' Name='" + $InternalName + "' StaticName='" + $InternalName + "' 
					DisplayName='" + $DisplayName + "' Format='DateOnly' ><Default>[Today]</Default></Field>"
                    Write-Host $schema
                    Add-PnPFieldFromXml -FieldXml $schema
                }
                else {
                    if ($Required) {
                        Write-Host -ForegroundColor Yellow "El Campo  es Requerido"
                        Add-PnPField -DisplayName $DisplayName -InternalName $InternalName -Type $FieldType -Group $Group -Required
                    }
                    else {
                        Write-Host -ForegroundColor Yellow "El Campo NO es Requerido"
                        Add-PnPField -DisplayName $DisplayName -InternalName $InternalName -Type $FieldType -Group $Group 
                    }
                }
            }
        }
        Write-Host   "Campo '$InternalName' creado" -ForegroundColor Green
    }	
}


Function New-SiteContentType() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$ContentTypeId,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Description = $null,

        [Parameter(Mandatory = $false)]
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$LocalizedNames = $null,

        [Parameter(Mandatory = $false)]
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$LocalizedDescriptions = $null,

        [Parameter(Mandatory = $true)]
        [string]$Group,

        [Parameter(Mandatory = $false)]
        [string]$DisplayFormUrl = $null,

        [Parameter(Mandatory = $false)]
        [string]$EditFormUrl = $null,

        [Parameter(Mandatory = $false)]
        [string]$NewFormUrl = $null,

        [Parameter(Mandatory = $false)]
        [bool]$Hidden = $false,

        [Parameter(Mandatory = $false)]
        [System.Xml.XmlElement]$Fields = $null		
    )
    Process {
        $contentType = Get-PnPContentType | Where-Object { $_.Name -eq $Name }
        if ($contentType.Name -ne $null) {
            Write-Host -ForegroundColor Yellow  "El tipo de contenido '$ContentTypeId' ya existe, se modificará..."            
        }
        else {
            Add-PnPContentType -Name $Name -ContentTypeId $ContentTypeId -Description $Description -Group $Group 
            Write-Host -ForegroundColor Green  "Tipo de contenido '$ContentTypeId' creado"
        }
        Foreach ($item in $Fields.Add) {			
            if ($item.Required -eq "True") {
                Add-PnPFieldToContentType -Field $item.InternalName -ContentType $Name -Required
            }
            else {
                Add-PnPFieldToContentType -Field $item.InternalName -ContentType $Name 
            }
            Write-Host -ForegroundColor Green "Campo anyadido al Tipo de Contenido '"$item.InternalName"'"
        }   
    }
}