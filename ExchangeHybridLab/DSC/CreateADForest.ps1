Configuration Main
{

	Param ( 
	
		[Parameter(Mandatory)]
		[string] $nodeName, 

		[Parameter(Mandatory)]
		[String]$DomainName,

		[Parameter(Mandatory)]
		[PSCredential]$AdminCreds

	)

	[Int]$RetryCount=20
	[Int]$RetryIntervalSec=30

	Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xDisk, xNetworking, xPendingReboot, cDisk
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($AdminCreds.UserName)", $AdminCreds.Password)

	Node $nodeName
		{
			File CreateFile {
				DestinationPath = 'C:\Temp\Test.txt'
				Ensure = "Present"
				Contents = 'Hello World!'
			}

			File CreateFile {
				DestinationPath = 'C:\Temp\Test2.txt'
				Ensure = "Present"
				Contents = 'Hello World!'
			}

			Log AfterDirectoryCopy
			{
				# The message below gets written to the Microsoft-Windows-Desired State Configuration/Analytic log
				Message = "Finished running the file resource with ID CreateFile"
				DependsOn = "[File]CreateFile" # This means run "CreateFile" first.
			}
		}
	}