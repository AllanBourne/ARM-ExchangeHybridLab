Configuration Main
{

Param ( [string]$SourcePath, [string]$TargetFolder, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

Import-DscResource -ModuleName PSDesiredStateConfiguration

	$TargetPath = $TargetFolder.TrimEnd("\").Replace("\\","\") + "\" + $sourcepath.Split("/")[$sourcepath.Split("/").Length-1]

	Node localhost
	{
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true            
        } 

		Script DownloadAADConnect
		{
			TestScript = {
				Test-Path $TargetPath
			}
			SetScript ={
				Invoke-WebRequest $SourcePath -OutFile $TargetPath
			}
			GetScript = {@{Result = "DownloadAADConnect"}}
		}

		Script InstallAADConnect
		{
			TestScript = {
				if (get-childitem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\" | Get-ItemProperty -Name DisplayName -ErrorAction SilentlyContinue | where {$_.DisplayName -like "Microsoft Azure AD Connect"}) { $true } else {$false}
			}
			SetScript ={
				$appArgs = "/q"
				Start-Process $TargetPath $appArgs -PassThru | Wait-Process
			}
			GetScript = {@{Result = "InstallAADConnect"}}
			DependsOn = "[Script]DownloadAADConnect"

		}

	}

}