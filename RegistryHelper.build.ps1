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
    remove bin, obj, out
}

task Pack {
    $manifest = "bin\$Configuration\$Framework\RegistryHelper.psd1"
    $version = (Import-PowerShellDataFile -LiteralPath $manifest).ModuleVersion
    $output = "out\$Configuration\$Framework\RegistryHelper\$version"

    if (Test-Path -LiteralPath $output -PathType Container) {
        Remove-Item -Path $output\* -Recurse -Force
    }
    else {
        New-Item -Path $output -ItemType Directory > $null
    }

    $params = @{
        Path        = "bin\$Configuration\$Framework\publish\RegistryHelper.*", "en-US", "ja-JP"
        Destination = $output
        Recurse     = $true
    }
    Copy-Item @params
}

task Test {
    $module = "$PSScriptRoot\out\$Configuration\$Framework\RegistryHelper"
    $command = "& { Import-Module -Name '$module'; Invoke-Pester -Path '$PSScriptRoot' }"

    switch ($Framework) {
        "net5.0" {
            exec { pwsh -c $command }
        }

        "net462" {
            exec { powershell -Command $command }
        }
    }
}

task . Build, Pack
