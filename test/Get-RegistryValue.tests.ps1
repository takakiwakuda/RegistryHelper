#Requires -Module RegistryHelper

using namespace System
using namespace RegistryHelper

Set-StrictMode -Version 3.0

Describe "Get-RegistryValue" {
    Context "Path" {
        It "Throws an exception if the path does not exist" {
            { Get-RegistryValue -Path "TestDrive:\Foo" -ErrorAction Stop } |
            Should -Throw -ErrorId "PathNotFound,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if the root of the path does not exist" {
            { Get-RegistryValue -Path "Foo:" -ErrorAction Stop } |
            Should -Throw -ErrorId "PathNotFound,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if the path is not a registry" {
            { Get-RegistryValue -Path "TestDrive:" -ErrorAction Stop } |
            Should -Throw -ErrorId "NotRegistryProvider,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if access to the path is denied" {
            { Get-RegistryValue -Path "HKLM:\SAM\SAM" -ErrorAction Stop } |
            Should -Throw -ErrorId "SecurityException,RegistryHelper.GetRegistryValueCommand"
        }

        It "Should retrieve registry values" {
            Get-RegistryValue -Path "HKCU:\Console" |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with Recurse parameter" {
            Get-RegistryValue -Path "HKCU:\Console" -Recurse |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with Depth parameter" {
            Get-RegistryValue -Path "HKCU:\Console" -Depth 1 |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with ValueOption parameter" {
            $values = Get-RegistryValue -Path "HKCU:\Environment" -ValueOption DoNotExpandEnvironmentNames
            $values | Should -BeOfType ([RegistryValueInfo])

            $value = $values | Where-Object -Property Name -Value TEMP -EQ
            $value.Value | Should -Not -BeExactly $env:TEMP
            [Environment]::ExpandEnvironmentVariables($value.Value) | Should -BeExactly $env:TEMP
        }

        It "Should retrieve registry values even if the specified path contains wildcard characters" {
            Get-RegistryValue -Path "HKCU:\*" |
            Should -BeOfType ([RegistryValueInfo])
        }
    }

    Context "LiteralPath" {
        It "Throws an exception if the path does not exist" {
            { Get-RegistryValue -LiteralPath "TestDrive:\Foo" -ErrorAction Stop } |
            Should -Throw -ErrorId "PathNotFound,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if the root of the path does not exist" {
            { Get-RegistryValue -LiteralPath "Foo:" -ErrorAction Stop } |
            Should -Throw -ErrorId "PathNotFound,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if the path is not a registry" {
            { Get-RegistryValue -LiteralPath "TestDrive:" -ErrorAction Stop } |
            Should -Throw -ErrorId "NotRegistryProvider,RegistryHelper.GetRegistryValueCommand"
        }

        It "Throws an exception if access to the path is denied" {
            { Get-RegistryValue -LiteralPath "HKLM:\SAM\SAM" -ErrorAction Stop } |
            Should -Throw -ErrorId "SecurityException,RegistryHelper.GetRegistryValueCommand"
        }

        It "Should retrieve registry values" {
            Get-RegistryValue -LiteralPath "HKCU:\Console" |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with Recurse parameter" {
            Get-RegistryValue -LiteralPath "HKCU:\Console" -Recurse |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with Depth parameter" {
            Get-RegistryValue -LiteralPath "HKCU:\Console" -Depth 1 |
            Should -BeOfType ([RegistryValueInfo])
        }

        It "Should retrieve registry values with ValueOption parameter" {
            $values = Get-RegistryValue -LiteralPath "HKCU:\Environment" -ValueOption DoNotExpandEnvironmentNames
            $values | Should -BeOfType ([RegistryValueInfo])

            $value = $values | Where-Object -Property Name -Value TEMP -EQ
            $value.Value | Should -Not -BeExactly $env:TEMP
            [Environment]::ExpandEnvironmentVariables($value.Value) | Should -BeExactly $env:TEMP
        }

        It "Throws an exception if the specified path contains wildcard characters" {
            { Get-RegistryValue -LiteralPath "HKCU:\*" -ErrorAction Stop } |
            Should -Throw -ErrorId "PathNotFound,RegistryHelper.GetRegistryValueCommand"
        }
    }
}
