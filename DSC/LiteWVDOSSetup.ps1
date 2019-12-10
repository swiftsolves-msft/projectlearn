Configuration LiteWVDOSSetup {

    param(
                    [parameter(Mandatory=$true)][string]$Prof
            )

    Install-Module 'xPSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration'

    Node $env:ComputerName
    {

        File CreateFolder
        {
            DestinationPath = 'C:\Temp'
            Type = 'Directory'
            Ensure = 'Present'
        }

        File CreateFolder2
        {
            DestinationPath = 'C:\Temp\fslogix'
            Type = 'Directory'
            Ensure = 'Present'
            DependsOn = '[File]CreateFolder'
        }

        xRemoteFile FSLogixagent
        {
            Uri = 'https://aka.ms/fslogix_download'
            DestinationPath = 'c:\temp\fslogix.zip'
            DependsOn = '[File]CreateFolder'
        }
    
        xArchive FSLogixzip
        {
            Path = 'c:\temp\fslogix.zip'
            Destination = 'c:\temp\fslogix'
            Validate = $true
            Force = $true
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]FSLogixagent'
        }

        Package InstallFSlogix
        {
            Ensure = 'Present'
            Name = 'Microsoft FSLogix Apps'
            Path = 'c:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe'
            ProductId = 'A39E5132-620C-4978-AE0C-F925D685E5E6'
            DependsOn = '[xArchive]FSLogixzip'
        }

        
        Registry ProfileEnable
              {
                     Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles"
            ValueName   = "Enabled"
            ValueData   = 1
            ValueType   = "DWORD"
            DependsOn   = '[Package]InstallFSlogix'
              }
              
        Registry ProfileLocation
              {
                     Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles"
            ValueName   = "VHDLocations"
            ValueData   = $Prof
            DependsOn   = '[Package]InstallFSlogix'
              }

    }
} 