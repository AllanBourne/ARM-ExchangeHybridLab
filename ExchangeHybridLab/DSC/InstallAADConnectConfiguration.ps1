Configuration Main
{

Param ( [string]$SourcePath, [string]$TargetPath, [Int]$RetryCount=20, [Int]$RetryIntervalSec=30 )

Import-DscResource -ModuleName PSDesiredStateConfiguration
	
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
				Test-Path ($Using:TargetPath).Replace("\\","\")
			}
			SetScript ={
                $fldr = $using:TargetPath
                $fldr = $fldr.Substring(0,$fldr.LastIndexOf("\")).TrimEnd("\").Replace("\\","\")
				if (-not (test-Path $fldr)) { New-Item $fldr -Type Directory }
                Invoke-WebRequest $Using:SourcePath -OutFile ($Using:TargetPath).Replace("\\","\")
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
				Start-Process (($Using:TargetPath).Replace("\\","\")) $appArgs -PassThru | Wait-Process
			}
			GetScript = {@{Result = "InstallAADConnect"}}
			DependsOn = "[Script]DownloadAADConnect"

		}

	}

}