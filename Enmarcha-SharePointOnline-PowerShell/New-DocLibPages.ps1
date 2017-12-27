#
# New_DocLibPages.ps1
#

Param
(
  [Parameter(Mandatory=$true)]
  [string]$Web
)
Process
{
	Get-ChildItem -Path $Path -Filter "PAGE-*" | % {
			$page = & "$currentPath\New-Page.ps1" -Path $_.FullName -Web $web
	}
}

