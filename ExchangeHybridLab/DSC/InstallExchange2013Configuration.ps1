Configuration Main
{

	Param ( [PSCredential]$AdminCredential, [string]$DomainName, [string]$domainNameNetbios, [string]$ExchangeOrgName, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

	Import-DscResource -ModuleName PSDesiredStateConfiguration, xDisk, xNetworking, xPendingReboot, cDisk, xExchange
    [PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${domainNameNetbios}\$($AdminCredential.UserName)", $AdminCredential.Password)


	Node "lclab09exch01"
		{

		LocalConfigurationManager            
		{            
			ActionAfterReboot = 'ContinueConfiguration'            
			ConfigurationMode = 'ApplyOnly'            
			RebootNodeIfNeeded = $true            
		} 

		xWaitforDisk Disk2
		{
				DiskNumber = 2
				RetryIntervalSec =$RetryIntervalSec
				RetryCount = $RetryCount
		}

		cDiskNoRestart ADDataDisk
		{
			DiskNumber = 2
			DriveLetter = "F"
		}

		WindowsFeature ASHTTPActivation
		{
			Ensure = "Present" 
			Name = "AS-HTTP-Activation"
		}

		WindowsFeature DesktopExperience
		{
			Ensure = "Present" 
			Name = "Desktop-Experience"
		}

		WindowsFeature NETFramework45Features
		{
			Ensure = "Present" 
			Name = "NET-Framework-45-Features"
		}

		WindowsFeature RPCoverHTTPproxy
		{
			Ensure = "Present" 
			Name = "RPC-over-HTTP-proxy"
		}


		WindowsFeature RSATClustering
		{
			Ensure = "Present" 
			Name = "RSAT-Clustering"
		}

		WindowsFeature RSATADDS
		{
			Ensure = "Present" 
			Name = "RSAT-ADDS"
		}

		WindowsFeature RSATClusteringCmdInterface
		{
			Ensure = "Present" 
			Name = "RSAT-Clustering-CmdInterface"
		}

		WindowsFeature RSATClusteringMgmt
		{
			Ensure = "Present" 
			Name = "RSAT-Clustering-Mgmt"
		}

		WindowsFeature RSATClusteringPowerShell
		{
			Ensure = "Present" 
			Name = "RSAT-Clustering-PowerShell"
		}

		WindowsFeature WebMgmtConsole
		{
			Ensure = "Present" 
			Name = "Web-Mgmt-Console"
		}

		# Two
		WindowsFeature WASProcessModel
		{
			Ensure = "Present" 
			Name = "WAS-Process-Model"
		}

		WindowsFeature WebAspNet45
		{
			Ensure = "Present" 
			Name = "Web-Asp-Net45"
		}

		WindowsFeature WebBasicAuth
		{
			Ensure = "Present" 
			Name = "Web-Basic-Auth"
		}

		WindowsFeature WebClientAuth
		{
			Ensure = "Present" 
			Name = "Web-Client-Auth"
		}

		WindowsFeature WebDigestAuth
		{
			Ensure = "Present" 
			Name = "Web-Digest-Auth"
		}

		WindowsFeature WebDirBrowsing
		{
			Ensure = "Present" 
			Name = "Web-Dir-Browsing"
		}

		WindowsFeature WebDynCompression
		{
			Ensure = "Present" 
			Name = "Web-Dyn-Compression"
		}
	  
		WindowsFeature WebHttpErrors
		{
			Ensure = "Present" 
			Name = "Web-Http-Errors"
		}

		# Three
		WindowsFeature WebHttpLogging
		{
			Ensure = "Present" 
			Name = "Web-Http-Logging"
		}

		WindowsFeature WebHttpRedirect
		{
			Ensure = "Present" 
			Name = "Web-Http-Redirect"
		}

		WindowsFeature WebHttpTracing
		{
			Ensure = "Present" 
			Name = "Web-Http-Tracing"
		}

		WindowsFeature WebISAPIExt
		{
			Ensure = "Present" 
			Name = "Web-ISAPI-Ext"
		}

		WindowsFeature WebISAPIFilter
		{
			Ensure = "Present" 
			Name = "Web-ISAPI-Filter"
		}

		WindowsFeature WebLgcyMgmtConsole
		{
			Ensure = "Present" 
			Name = "Web-Lgcy-Mgmt-Console"
		}

		WindowsFeature WebMetabase
		{
			Ensure = "Present" 
			Name = "Web-Metabase"
		}

		# four
		WindowsFeature WebMgmtService
		{
			Ensure = "Present" 
			Name = "Web-Mgmt-Service"
		}

		WindowsFeature WebNetExt45
		{
			Ensure = "Present" 
			Name = "Web-Net-Ext45"
		}

		WindowsFeature WebRequestMonitor
		{
			Ensure = "Present" 
			Name = "Web-Request-Monitor"
		}

		WindowsFeature WebServer
		{
			Ensure = "Present" 
			Name = "Web-Server"
		}

		WindowsFeature WebStatCompression
		{
			Ensure = "Present" 
			Name = "Web-Stat-Compression"
		}

		WindowsFeature WebStaticContent
		{
			Ensure = "Present" 
			Name = "Web-Static-Content"
		}
		
		WindowsFeature WebWindowsAuth
		{
			Ensure = "Present" 
			Name = "Web-Windows-Auth"
		} 

		WindowsFeature WebWMI
		{
			Ensure = "Present" 
			Name = "Web-WMI"
		}

		WindowsFeature WindowsIdentityFoundation
		{
			Ensure = "Present" 
			Name = "Windows-Identity-Foundation"
		}
		
		Script CreateFolderDownloads
		{
			TestScript = {
				Test-Path "f:\Downloads"
			}
			SetScript ={
				New-Item f:\downloads -ItemType Directory
			}
			GetScript = {@{Result = "CreateFolderDownloads"}}
		}


		Script DownloadExchange2013CU12
		{
			TestScript = {
				Test-Path "F:\downloads\Exchange2013-x64-cu12.exe"
			}
			SetScript ={
				$source = "https://download.microsoft.com/download/2/C/1/2C151059-9B2A-466B-8220-5AE8B829489B/Exchange2013-x64-cu12.exe"
				$dest = "F:\downloads\Exchange2013-x64-cu12.exe"
				Invoke-WebRequest $source -OutFile $dest
			}
			GetScript = {@{Result = "DownloadExchange2013CU12"}}
		}

		Script UnifiedCommunicationsManagedAPI4Runtime
		{
			TestScript = {
				Test-Path "F:\downloads\UcmaRuntimeSetup.exe"
			}
			SetScript ={
				$source = "https://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
				$dest = "F:\downloads\UcmaRuntimeSetup.exe"
				Invoke-WebRequest $source -OutFile $dest
			}
			GetScript = {@{Result = "UnifiedCommunicationsManagedAPI4Runtime"}}
		}

		Script UnpackExchange
		{
			TestScript = {
				Test-Path "f:downloads\Exchange2013Source\setup.exe"
			}
			SetScript ={
				$FilePath = "F:\downloads\Exchange2013-x64-cu12.exe"
				$ExtractLocation = "f:\downloads\Exchange2013Source\"
				$appArgs = '/quiet /extract:"' + $ExtractLocation + '"'
				Start-Process $FilePath $appArgs -PassThru | Wait-Process
			}
			GetScript = {@{Result = "UnpackExchange"}}
			DependsOn = "[Script]DownloadExchange2013CU12"
		}

		Script InstallUnifiedCommunicationsManagedAPI4Runtime
		{

			TestScript = {
				if (Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\UCMA4" -erroraction SilentlyContinue) {$true} Else {$false}
			}
			SetScript ={
				$FilePath = "F:\downloads\UcmaRuntimeSetup.exe"
				$appArgs = "/quiet /norestart"
				Start-Process $FilePath $appArgs -PassThru | Wait-Process
			}
			GetScript = {@{Result = "InstallUnifiedCommunicationsManagedAPI4Runtime"}}
			DependsOn = "[Script]UnifiedCommunicationsManagedAPI4Runtime"

		}

		xPendingReboot BeforeExchangeInstall
		{
			Name      = "BeforeExchangeInstall"
		}

		xExchInstall InstallExchange
		{
			Path       = "f:downloads\Exchange2013Source\setup.exe"
			Arguments  = "/mode:Install /role:Mailbox,ClientAccess /Iacceptexchangeserverlicenseterms /OrganizationName:$ExchangeOrgName"
			Credential = $DomainCreds
			DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
		}

		xPendingReboot AfterExchangeInstall
		{
			Name      = "AfterExchangeInstall"
			DependsOn = '[xExchInstall]InstallExchange'
		}

	}

}