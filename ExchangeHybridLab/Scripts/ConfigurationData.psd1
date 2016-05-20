#
# ConfigurationData.psd1
#

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName="*";
            PSDscAllowPlainTextPassword=$true;
			PSDscAllowDomainUser = $true;
         }
	)
}