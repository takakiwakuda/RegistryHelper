[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("Debug", "Release")]
    [string]
    $Configuration = "Debug",

    [Parameter()]
    [ValidateSet("net5.0", "net462")]
    [string]
    $Framework = "net5.0"
)

task Build @{
    Inputs  = Get-ChildItem -Path *.cs, *.csproj
    Outputs = "bin\$Configuration\$Framework\RegistryHelper.dll"
    Jobs    = {
        exec { dotnet publish -c $Configuration -f $Framework }
    }
}

task Clean {
    remove bin, obj
}

task . Build
