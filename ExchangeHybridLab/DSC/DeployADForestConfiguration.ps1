Configuration Main
{

Param ( [PSCredential]$AdminCredential, [string]$DomainName, [string]$domainNameNetbios, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xDisk, xNetworking, xPendingReboot, cDisk, xOU
[PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${domainNameNetbios}\$($AdminCredential.UserName)", $AdminCredential.Password)

	Node localhost
	{
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        } 

        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
        }

		xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
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

		WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
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

		WindowsFeature InstallRSATADPowerShell
        {            
            Ensure = "Present"
            Name = "RSAT-AD-PowerShell"
        }
		
		
		xADOrganizationalUnit ServersOU
        {
            Ensure = "Present"
            Name = "Servers"
            Path = (Get-ADDomain).DistinguishedName
            Credential = $DomainCreds
            ProtectedFromAccidentalDeletion = "Yes"
            Description = "This is a sample OU"
            DependsOn = "[WindowsFeature]InstallRSATADPowerShell"
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

	}

}