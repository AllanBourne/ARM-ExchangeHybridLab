Configuration Main
{

Param ( [string]$nodeName, [PSCredential]$AdminCredential, [string]$DomainName, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xDisk, xNetworking, xPendingReboot, cDisk
[PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($AdminCredential.UserName)", $AdminCredential.Password)

	Node $nodeName
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

	}

}