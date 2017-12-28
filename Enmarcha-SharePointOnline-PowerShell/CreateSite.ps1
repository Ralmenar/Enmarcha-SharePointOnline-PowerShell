#
# CreateSite.ps1
#
Param
(
    [Parameter(Mandatory=$true)]
    [string]$Tenant = $(Read-Host -Prompt "Tenant"),  
    [Parameter(Mandatory=$true)]
    [string]$UrlWebApplication = $(Read-Host -Prompt "Url"),  
    [Parameter(Mandatory=$true)]  
    [string]$OwnerAlias =  $(Read-Host -Prompt "dominioOwnerAlias"),	
	[Parameter(Mandatory=$true)]  
    [string]$PathConfiguration =  $(Read-Host -Prompt "Path Configuration"),
    [switch]$Force,
	[switch]$ConfigurationRelative
)
Process
{
	Function Process-Folder()
	{
		Param
        (
			[Parameter(Mandatory=$true)]
			[string]$Tenant = $(Read-Host -Prompt "Tenant"),  
            [Parameter(Mandatory=$true)]
            [string]$Path,		
            [Parameter(Mandatory=$true)]
            [string]$UrlWebApplication,
			[Parameter(Mandatory=$true)]
			[System.Management.Automation.PSCredential]$credentials 
        )
	   Process
        {
						

            Write-Host -ForegroundColor Cyan "comenzando a procesar la carpeta $Path"					
			Get-ChildItem -Path $Path -Filter "LIST-*" | % {
                $list = & "$currentPath\New-List.ps1" -Path $_.FullName -tenant $Tenant -UrlWebApplication $UrlWebApplication -Credentials $credentials
            }
			Get-ChildItem -Path $Path -Filter "DOCLIB-*" | % {
                $list = & "$currentPath\New-DocLib.ps1" -Path $_.FullName -tenant $Tenant -UrlWebApplication $UrlWebApplication -Credentials $credentials
            }
			Get-ChildItem -Path $Path -Filter "LIB-*" | % {
                $list = & "$currentPath\New-List.ps1" -Path $_.FullName -tenant $Tenant -UrlWebApplication $UrlWebApplication -Credentials $credentials 
            }
			Get-ChildItem -Path $Path -Filter "WEB-*" | % {
                $list = & "$currentPath\New-Web.ps1" -Path $_.FullName -tenant $Tenant -UrlWebApplication $UrlWebApplication -Credentials $credentials 
				Process-Folder -Path $_.FullName -tenant $Tenant -UrlWebApplication $UrlWebApplication -credentials $credentials
            }
	    }
	}
   
	Clear-Host

   $install= 	Get-Module SharePointPnPPowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
	if ($install -eq $null)
	{
		Install-Module SharePointPnPPowerShellOnline -SkipPublisherCheck -AllowClobber
	}
   $currentPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
   Import-Module "$currentPath\ContentTypeXmlFunctions.psm1" -PassThru -Force -DisableNameChecking | Out-Null
   Import-Module "$currentPath\EnmarchaFunctions.psm1" -PassThru -Force -DisableNameChecking | Out-Null

   #PowerShell ISE no soporta Start-Transcript
   if($Host.Name -notmatch "ISE")
   {
        $ErrorActionPreference = "SilentlyContinue"
        Stop-Transcript | out-null
        $ErrorActionPreference = "Continue"
        Start-Transcript -path "$currentPath\last script transcript.log" -ErrorAction Continue
	}
	
	$credential= Get-Credential

    Set-PnPTraceLog -On -LogFile traceoutput.txt
	Write-Host -ForegroundColor DarkBlue "Empezando el aprovionamiento"
	$createWeb="$Tenant$($UrlWebApplication)"
	
	Connect-PnPOnline -Url $Tenant -Credentials $credential
	$result= & "$currentPath\New-Site.ps1" -UrlWebApplication $UrlWebApplication -tenant $Tenant -PathConfiguration "$PathConfiguration" -Path "$PathConfiguration"  -OwnerAlias $OwnerAlias -Credentials $credential
	
	Connect-PnPOnline -Url $createWeb -Credentials $credential
	$ctx = Get-PnPContext
	
	#Creo los grupos 
		Get-ChildItem -Path $PathConfiguration -Filter "GROUP" | % {
				$list = & "$currentPath\New-Group.ps1" -Path $_.FullName
			}
	##Creo la taxonomia
	Get-ChildItem -Path $PathConfiguration -Filter "TAXONOMY" | % {
				$list = & "$currentPath\New-Taxonomy.ps1" -Path $_.FullName
			}
	###Creo las Columnas de Sitio
	Get-ChildItem -Path $PathConfiguration -Filter "SiteColumns*"   | % {
		Write-Host "Procesando el XML del fichero" + $_.FullName
		Import-ContentTypesXmlFiles -Path $_.FullName -ContentTypeMinVersion $ContentTypeMinVersion -ContentTypeMaxVersion $ContentTypeMaxVersion 
	}
	#Creo los Tipos de Contenidos
	Get-ChildItem -Path $PathConfiguration -Filter "*ContentType*"   | % {
		Write-Host "Procesando el XML del fichero" + $_.FullName
		Import-ContentTypesXmlFiles -Path $_.FullName -ContentTypeMinVersion $ContentTypeMinVersion -ContentTypeMaxVersion $ContentTypeMaxVersion 
	}

	Write-Host "Iniciando la carpeta $PathConfiguration" -ForegroundColor Green			
	Process-Folder -Path "$PathConfiguration" -UrlWebApplication $UrlWebApplication -tenant $Tenant	-credentials $credential
	Write-Host "Finalizando la carpeta $PathConfiguration" -ForegroundColor Green
	
	#Lookup
	Write-Host -ForegroundColor DarkBlue "Creando campos Lookup"
	$item= & "$currentPath\AddLookup.ps1" -tenant $Tenant -UrlWebApplication $UrlWebApplication -credentials $credential -path $PathConfiguration
	Write-Host -ForegroundColor Green "Campos Lookup creados correctamente"	

	Write-Host -ForegroundColor Magenta "Creando items"
	$items = & "$currentPath\AddItems.ps1"  -tenant $Tenant -UrlWebApplication $UrlWebApplication -credentials $credential -CurrentPath $currentPath -Path $PathConfiguration
	Write-Host -ForegroundColor DarkCyan "Items creados correctamente"

    Write-Host "Despliegue completado" -ForegroundColor Green	
}