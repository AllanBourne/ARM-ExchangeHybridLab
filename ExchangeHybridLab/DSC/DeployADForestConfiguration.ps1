Configuration Main
{

	Param ( [PSCredential]$AdminCredential, [string]$DomainName, [string]$domainNameNetbios, [string]$domainDN, [string]$SourcePath, [string]$TargetPath, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xDisk, xNetworking, xPendingReboot, cDisk, xOU, xSystemSecurity
	Import-DSCResource -Module MSFT_xSystemSecurity -Name xIEEsc
	[PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${domainNameNetbios}\$($AdminCredential.UserName)", $AdminCredential.Password)


	Node localhost
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

        xIEEsc DisableIEEsc
        {
            IsEnabled = $false
            UserRole = "Users"
        }

        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
        }

		WindowsFeature AADRSAT 
        { 
            Ensure = "Present" 
            Name = "RSAT-ADDS-Tools"
        }

		WindowsFeature DNSRSAT
        { 
            Ensure = "Present" 
            Name = "RSAT-DNS-Server"
        }

		WindowsFeature ADSPSRSAT
        {            
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
        }

		xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }
  
  		Script SetDNSForwarders
		{
			TestScript = {
				if (Get-DnsServerForwarder | where {$_.IPAddress -eq "8.8.8.8"}) { $true } Else { $false }
			}
			SetScript ={
				Add-DnsServerForwarder -IPAddress "8.8.8.8"
			}
			GetScript = {@{Result = "SetDNSForwarders"}}
			DependsOn = "[WindowsFeature]DNS"
		}


        xADDomain FirstDS 
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
            DependsOn = "[WindowsFeature]ADDSInstall","[xDnsServerAddress]DnsServerAddress","[cDiskNoRestart]ADDataDisk"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential = $DomainCreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        } 

        xPendingReboot Reboot1
        { 
            Name = "RebootServer"
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

		xADOrganizationalUnit ServersOU
        {
            Ensure = "Present"
            Name = "Servers"
            Path = $domainDN
            Credential = $DomainCreds
            ProtectedFromAccidentalDeletion = "Yes"
            Description = "Servers OU"
            DependsOn = "[xWaitForADDomain]DscForestWait","[xPendingReboot]Reboot1"
        }

		Script DownloadAADConnect
		{
			TestScript = {
				Test-Path ($Using:TargetPath).Replace("\\","\")
			}
			SetScript ={
                $fldr = $using:TargetPath
                $fldr = $fldr.Substring(0,$fldr.LastIndexOf("\")).TrimEnd("\").Replace("\\","\")
				if (-not (test-Path $fldr)) { New-Item $fldr -Type Directory }
                Invoke-WebRequest $Using:SourcePath -OutFile ($Using:TargetPath).Replace("\\","\")
			}
			GetScript = {@{Result = "DownloadAADConnect"}}
			DependsOn = "[xWaitForADDomain]DscForestWait","[xPendingReboot]Reboot1"
		}

		Script InstallAADConnect
		{
			TestScript = {
				if (get-childitem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty -Name DisplayName -ErrorAction SilentlyContinue | where {$_.DisplayName -like "Microsoft Azure AD Connect"}) { $true } else {$false}
			}
			SetScript ={
				$appArgs = "/q"
				Start-Process (($Using:TargetPath).Replace("\\","\")) $appArgs -PassThru | Wait-Process
			}
			GetScript = {@{Result = "InstallAADConnect"}}
			DependsOn = "[Script]DownloadAADConnect"

		}

	}

}