---
external help file: RegistryHelper.dll-Help.xml
Module Name: RegistryHelper
online version: https://github.com/takakiwakuda/RegistryHelper/blob/main/doc/Get-RegistryValue.md
schema: 2.0.0
---

# Get-RegistryValue

## SYNOPSIS

Retrieves one or more values from the registry.

## SYNTAX

### Path

```powershell
Get-RegistryValue [-Path] <String[]> [-Recurse] [-Depth <UInt32>] [-ValueOption <RegistryValueOptions>] [<CommonParameters>]
```

### LiteralPath

```powershell
Get-RegistryValue -LiteralPath <String[]> [-Recurse] [-Depth <UInt32>] [-ValueOption <RegistryValueOptions>] [<CommonParameters>]
```

## DESCRIPTION

The Get-RegistryValue cmdlet retrieves one or more values from the registry.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-RegistryValue -Path "HKCU:\Environment"
```

This example retrieves values from the registry `HKEY_CURRENT_USER\Environment`.

## PARAMETERS

### -Depth

Specifies the registry subkey level to retrieve.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath

Specifies the path to the registry.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath, LP

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

Specifies the path to the registry. Accepts wildcard characters.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse

Retrieves values from the specified registry and its subkeys.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValueOption

Specifies the behavior when retrieving values from the registry.

```yaml
Type: RegistryValueOptions
Parameter Sets: (All)
Aliases:
Accepted values: None, DoNotExpandEnvironmentNames

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

You can pipe a registry path to `Get-RegistryValue`.

## OUTPUTS

### RegistryHelper.RegistryValueInfo

`Get-RegistryValue` returns information about registry values.

## NOTES

## RELATED LINKS
