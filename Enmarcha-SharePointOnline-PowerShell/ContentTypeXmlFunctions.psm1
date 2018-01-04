$currentPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Import-Module "$currentPath\ContentTypeFunctions.psm1" -PassThru -Force -DisableNameChecking | Out-Null

Function Get-LocalizedDescriptionResourcesDictionary() {
    Param
    (
        [Parameter(Mandatory = $false)]
        [System.Xml.XmlElement]$Xml = $null
    )
    Process {
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$descriptionResources = $null
        if ($Xml.DescriptionResource -ne $null -and $Xml.DescriptionResource -ne "") {
            $descriptionResources = New-Object "System.Collections.Generic.Dictionary``2[System.Globalization.CultureInfo,string]"
            $Xml.DescriptionResource | % {
                $cultureInfo = New-Object System.Globalization.CultureInfo($_.Label)
                $descriptionResources.Add($cultureInfo, $_.Value)
            }
        }

        return $descriptionResources
    }
}

Function Get-StringArrayFromChoices() {
    Param
    (
        [Parameter(Mandatory = $false)]
        [string]$Choices = $null
    )
    Process {
        if ($Choices -eq $null -or $Choices -eq "") { return $null }
        return ($Choices.Split(";#", [System.StringSplitOptions]::RemoveEmptyEntries))
    }
}

Function Get-LocalizedDisplayNamesDictionary() {
    Param
    (
        [Parameter(Mandatory = $false)]
        [System.Xml.XmlElement]$Xml = $null
    )
    Process {
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$displayNames = $null
        if ($Xml.DisplayName -ne $null -and $Xml.DisplayName -ne "") {
            $displayNames = New-Object "System.Collections.Generic.Dictionary``2[System.Globalization.CultureInfo,string]"
            $Xml.DisplayName | % {
                $cultureInfo = New-Object System.Globalization.CultureInfo($_.Label)
                $displayNames.Add($cultureInfo, $_.Value)
            }
        }

        return $displayNames
    }
}

Function New-SiteColumnFromXml() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$Xml,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credentials
    )
    Process {
        Write-Host "Iniciando función New-SiteColumnFromXml en el sitio Xml: $($Xml.OuterXml)"

        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$displayNames = Get-LocalizedDisplayNamesDictionary -Xml $Xml.DisplayNames

        if ($displayNames -eq $null) {
            $displayName = $Xml.Name
        }
        else {
            $displayName = $displayNames.Values | Select-Object -First 1
        }

        New-SiteColumn  -FieldType $Xml.FieldType -InternalName $Xml.Name -Id ([System.Guid]::Parse($Xml.Id)) `
            -DisplayName $displayName -LocalizedDisplayNames $displayNames `
            -StaticName $Xml.StaticName -Group $Xml.Group `
            -Hidden (Get-BoolValueOrNull $Xml.Hidden) -Required (Get-BoolValueOrNull $Xml.Required) -Sealed (Get-BoolValueOrNull $Xml.Sealed) `
            -MaxLength $Xml.MaxLength `
            -ShowInDisplayForm (Get-BoolValueOrNull $Xml.ShowInDisplayForm) -ShowInEditForm (Get-BoolValueOrNull $Xml.ShowInEditForm) `
            -ShowInListSettings (Get-BoolValueOrNull $Xml.ShowInListSettings) -ShowInNewForm (Get-BoolValueOrNull $Xml.ShowInNewForm) `
			`
            -DateTimeFormat $Xml.DateTime.Format `
            -UrlFormat $Xml.Url.URLFormat `
            -ImageRichText $Xml.Image.RichText -ImageRichTextMode $Xml.Image.RichTextMode `
            -LinkRichText $Xml.Link.RichText -LinkRichTextMode $Xml.Link.RichTextMode `
            -NoteRichText $Xml.Note.RichText -NoteRichTextMode $Xml.Note.RichTextMode `
            -UnlimitedLengthInDocumentLibrary (Get-BoolValueOrNull $Xml.Note.UnlimitedLengthInDocumentLibrary) `
            -HtmlRichText $Xml.Html.RichText -HtmlRichTextMode $Xml.Html.RichTextMode `
            -CalculatedFormulaValueType $Xml.Calculated.FormulaValueType -CalculatedFormula $Xml.Calculated.Formula `
            -UserSelectionMode $xml.User.UserSelectionMode -UserAllowMultipleValues (Get-BoolValueOrNull $Xml.User.AllowMultipleValues) `
            -Choices (Get-StringArrayFromChoices $Xml.Choice.Choices) `
            -IsPathRendered (Get-BoolValueOrNull $Xml.TaxonomyFieldType.FullPathRendered) `
            -IsOpen (Get-BoolValueOrNull $Xml.TaxonomyFieldType.IsOpen) `
            -AllowMultipleValues (Get-BoolValueOrNull $Xml.TaxonomyFieldType.AllowMultipleValues) `
            -TermStoreGroupName $Xml.TaxonomyFieldType.TermStoreGroupName -TermSetName $Xml.TaxonomyFieldType.TermSetName `
            -CurrencyFormat $Xml.CurrencyFormat -DecimalFormat $Xml.DecimalFormat -Credentials $Credentials
    }
}


{
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$Xml,

        [Parameter(Mandatory = $true)]
        [string]$Web
    )
    Process {
        Write-Host  "Iniciando función Update-SiteColumnFromXml en el sitio: $($Web.Url) Xml: $($Xml.OuterXml)"
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$displayNames = Get-LocalizedDisplayNamesDictionary -Xml $Xml.DisplayNames
        if ($displayNames -eq $null) {
            $displayName = $Xml.Name
        }
        else {
            $displayName = $displayNames.Values | Select-Object -First 1
        }

        Update-SiteColumn -Web $Web -InternalName $Xml.Name `
            -LocalizedDisplayNames $displayNames `
            -StaticName $Xml.StaticName -Group $Xml.Group `
            -Hidden (Get-BoolValueOrNull $Xml.Hidden) -Required (Get-BoolValueOrNull $Xml.Required) -Sealed (Get-BoolValueOrNull $Xml.Sealed) `
            -MaxLength $Xml.MaxLength `
            -ShowInDisplayForm (Get-BoolValueOrNull $Xml.ShowInDisplayForm) -ShowInEditForm (Get-BoolValueOrNull $Xml.ShowInEditForm) `
            -ShowInListSettings (Get-BoolValueOrNull $Xml.ShowInListSettings) -ShowInNewForm (Get-BoolValueOrNull $Xml.ShowInDisplayForm) `
            -UpdateChildren $true -LogLevel $LogLevel `
            -DateTimeFormat $Xml.DateTime.Format `
            -UrlFormat $Xml.Url.URLFormat `
            -ImageRichText $Xml.Image.RichText -ImageRichTextMode $Xml.Image.RichTextMode `
            -LinkRichText $Xml.Link.RichText -LinkRichTextMode $Xml.Link.RichTextMode `
            -NoteRichText $Xml.Note.RichText -NoteRichTextMode $Xml.Note.RichTextMode `
            -UnlimitedLengthInDocumentLibrary (Get-BoolValueOrNull $Xml.Note.UnlimitedLengthInDocumentLibrary) `
            -HtmlRichText $Xml.Html.RichText -HtmlRichTextMode $Xml.Html.RichTextMode `
            -CalculatedFormulaValueType $Xml.Calculated.FormulaValueType -CalculatedFormula $Xml.Calculated.Formula `
            -UserSelectionMode $xml.User.UserSelectionMode -UserAllowMultipleValues (Get-BoolValueOrNull $Xml.User.AllowMultipleValues) `
            -Choices (Get-StringArrayFromChoices $Xml.Choice.Choices) `
            -IsPathRendered (Get-BoolValueOrNull $Xml.TaxonomyFieldType.FullPathRendered) `
            -IsOpen (Get-BoolValueOrNull $Xml.TaxonomyFieldType.IsOpen) `
            -AllowMultipleValues (Get-BoolValueOrNull $Xml.TaxonomyFieldType.AllowMultipleValues) `
            -TermStoreGroupName $Xml.TaxonomyFieldType.TermStoreGroupName -TermSetName $Xml.TaxonomyFieldType.TermSetName `
            -CurrencyFormat $Xml.CurrencyFormat -DecimalFormat $Xml.DecimalFormat
    }
}

Function Import-ContentTypesXmlFiles() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$ContentTypeMinVersion = $null,

        [Parameter(Mandatory = $false)]
        [string]$ContentTypeMaxVersion = $null,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credentials
    )
    Process {
        [string]$prefix = "ContentTypes-"
        Get-ChildItem -Path $Path -Filter "$prefix*" | Sort-Object -Property Name | % {
            [string]$version = $_.Name.Substring($prefix.Length).Split('-')[0]

            if ($ContentTypeMinVersion -eq $null -or $ContentTypeMinVersion -eq "" -or $version -ge $ContentTypeMinVersion) {
                if ($ContentTypeMaxVersion -eq $null -or $ContentTypeMaxVersion -eq "" -or $version -le $ContentTypeMaxVersion) {
                    Import-ContentTypeXmlFile -Path $_.FullName -Credentials $Credentials
                }
            }
        }
    }
}

Function New-SiteContentTypeFromXml() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$Xml,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credentials
    )
    Process {
        Write-Host "Iniciando función New-SiteContentTypeFromXml en el sitio: Xml: $($Xml.OuterXml)"

        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$names = Get-LocalizedDisplayNamesDictionary -Xml $Xml.DisplayNames
        [System.Collections.Generic.Dictionary[System.Globalization.CultureInfo, string]]$descriptions = Get-LocalizedDescriptionResourcesDictionary -Xml $Xml.DescriptionResources

        $hidden = $false
        if ($xml.Hidden -ne $null) { $hidden = [System.Convert]::ToBoolean($Xml.Required) }

        New-SiteContentType -ContentTypeId $Xml.Id `
            -Name $Xml.Name -Description $Xml.Description -LocalizedNames $names `
            -LocalizedDescriptions $descriptions `
            -Group $Xml.Group `
            -DisplayFormUrl $Xml.DisplayFormUrl -EditFormUrl $Xml.EditFormUrl -NewFormUrl $Xml.NewFormUrl `
            -Hidden $hidden `
            -Fields $Xml.Fields -Credentials $Credentials
    }
}

Function Import-ContentTypeXmlFile() {
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credentials	
    )
    Process {
        [xml]$manifest = Get-Content $Path -Encoding UTF8
        if ($manifest.Site.SiteColumns.Add -ne $null) {
            $manifest.Site.SiteColumns.Add | % {
                New-SiteColumnFromXml -Xml $_ -Credentials $Credentials | Out-Null
            }
        }
        
        if ($manifest.Site.ContentTypes.Add -ne $null) {
            $manifest.Site.ContentTypes.Add | % {
                New-SiteContentTypeFromXml -Xml $_ -Credentials $Credentials | Out-Null
            }
        }
    
    }
}