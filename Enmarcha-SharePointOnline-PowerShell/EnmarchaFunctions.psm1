#
# EnmarchaFunctions.psm1
#
Function Get-BoolValueOrNull()
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$Value = $null
    )
    Process
    {
        if ($Value -eq $null -or $Value -eq "") { return $null }
        return ([System.Convert]::ToBoolean($Value))
    }
}

Function Get-IntValueOrNull()
{
    Param
    (
        [Parameter(Mandatory=$false)]
        [string]$Value = $null
    )
    Process
    {
        if ($Value -eq $null -or $Value -eq "") { return $null }
        return ([System.Convert]::ToInt32($Value))
    }
}

function Convert-XmlElementToString
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $xml
    )

    if ($xml -eq '' -or $xml -eq $null) {
        return ''
    }

    $sw = [System.IO.StringWriter]::new()
    $xmlSettings = [System.Xml.XmlWriterSettings]::new()
    $xmlSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Fragment
    $xmlSettings.Indent = $true
    $xw = [System.Xml.XmlWriter]::Create($sw, $xmlSettings)
    $xml.WriteTo($xw)
    $xw.Close()
    return $sw.ToString()
}