﻿using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Management.Automation;
using System.Security;
using Microsoft.Win32;
using ProjectResources = RegistryHelper.Properties.Resources;

namespace RegistryHelper
{
    /// <summary>
    /// Get-RegistryValue cmdlet
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "RegistryValue", HelpUri = "https://github.com/takakiwakuda/RegistryHelper/blob/main/doc/Get-RegistryValue.md")]
    [OutputType(typeof(RegistryValueInfo))]
    public class GetRegistryValueCommand : PSCmdlet
    {
        /// <summary>
        /// Path parameter
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "Path", Position = 0, ValueFromPipeline = true)]
        [ValidateNotNullOrEmpty]
        public string[] Path
        {
            get
            {
                return _path;
            }
            set
            {
                _path = value;
            }
        }

        /// <summary>
        /// LiteralPath parameter
        /// </summary>
        [Parameter(Mandatory = true, ParameterSetName = "LiteralPath", ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty]
        [Alias("PSPath", "LP")]
        public string[] LiteralPath
        {
            get
            {
                return _path;
            }
            set
            {
                _isLiteralPath = true;
                _path = value;
            }
        }

        /// <summary>
        /// Recurse parameter
        /// </summary>
        [Parameter]
        public SwitchParameter Recurse
        {
            get
            {
                return _recurse;
            }
            set
            {
                _recurse = value;
            }
        }

        /// <summary>
        /// Depth parameter
        /// </summary>
        [Parameter]
        public uint Depth
        {
            get
            {
                return _depth;
            }
            set
            {
                _depth = value;
                _recurse = true;
            }
        }

        /// <summary>
        /// ValueOption parameter
        /// </summary>
        [Parameter]
        public RegistryValueOptions ValueOption
        {
            get
            {
                return _options;
            }
            set
            {
                _options = value;
            }
        }

        private uint _depth = uint.MaxValue;
        private bool _isLiteralPath;
        private RegistryValueOptions _options = RegistryValueOptions.None;
        private string[] _path = Array.Empty<string>();
        private bool _recurse;

        protected override void ProcessRecord()
        {
            foreach (string path in ResolvePath())
            {
                using RegistryKey? key = OpenRegistryKey(path);
                if (key is null)
                {
                    continue;
                }

                WriteObject(EnumerateRegistryValues(key, _depth), true);
            }
        }

        [SuppressMessage("csharp", "IDE0057")]
        private RegistryKey? OpenRegistryKey(string path)
        {
            int index = path.IndexOf('\\');

            RegistryKey baseKey = path.Substring(0, index) switch
            {
                "HKEY_CLASSES_ROOT" => Registry.ClassesRoot,
                "HKEY_CURRENT_USER" => Registry.CurrentUser,
                "HKEY_LOCAL_MACHINE" => Registry.LocalMachine,
                "HKEY_USERS" => Registry.Users,
                "HKEY_CURRENT_CONFIG" => Registry.CurrentConfig,
                _ => throw new NotSupportedException()
            };

            try
            {
                return baseKey.OpenSubKey(path.Substring(index + 1));
            }
            catch (Exception ex) when (ex is SecurityException or UnauthorizedAccessException)
            {
                ErrorRecord errorRecord = new(
                    ex,
                    ex.GetType().Name,
                    ErrorCategory.PermissionDenied,
                    path
                );
                WriteError(errorRecord);
            }

            return null;
        }

        private IEnumerable<RegistryValueInfo> EnumerateRegistryValues(RegistryKey key, uint depth)
        {
            foreach (string name in key.GetValueNames().OrderBy(n => n))
            {
                yield return new RegistryValueInfo()
                {
                    Hive = key.Name,
                    Name = name,
                    Value = key.GetValue(name, null, _options),
                    Type = key.GetValueKind(name)
                };
            }

            if (_recurse && depth > 0 && key.SubKeyCount > 0)
            {
                depth--;

                foreach (string subKeyName in key.GetSubKeyNames())
                {
                    using RegistryKey? subKey = key.OpenSubKey(subKeyName);
                    if (subKey is null)
                    {
                        WriteWarning($"Unable to open key '{subKey}'.");
                        continue;
                    }

                    foreach (RegistryValueInfo info in EnumerateRegistryValues(subKey, depth))
                    {
                        yield return info;
                    }
                }
            }
        }

        private IEnumerable<string> ResolvePath()
        {
            List<string> resolvedPaths = new();

            foreach (string path in _path)
            {
                List<string> paths = new();
                ProviderInfo provider;

                try
                {
                    if (!SessionState.InvokeProvider.Item.Exists(path, false, _isLiteralPath))
                    {
                        ErrorRecord errorRecord = new(
                            new ItemNotFoundException(string.Format(ProjectResources.PathNotFound, path)),
                            "PathNotFound",
                            ErrorCategory.ObjectNotFound,
                            path
                        );
                        WriteError(errorRecord);
                        continue;
                    }
                }
                catch (DriveNotFoundException ex)
                {
                    ErrorRecord errorRecord = new(ex.ErrorRecord, ex);
                    WriteError(errorRecord);
                    continue;
                }

                if (_isLiteralPath)
                {
                    paths.Add(SessionState.Path.GetUnresolvedProviderPathFromPSPath(path, out provider, out _));
                }
                else
                {
                    paths.AddRange(SessionState.Path.GetResolvedProviderPathFromPSPath(path, out provider));
                }

                if (!provider.Name.Equals("Registry", StringComparison.Ordinal))
                {
                    ErrorRecord errorRecord = new(
                        new InvalidOperationException(string.Format(ProjectResources.NotRegistryProvider, path)),
                        "NotRegistryProvider",
                        ErrorCategory.InvalidArgument,
                        path
                    );
                    WriteError(errorRecord);
                    continue;
                }

                resolvedPaths.AddRange(paths);
            }

            return resolvedPaths;
        }
    }

    public class RegistryValueInfo
    {
        public string? Hive { get; init; }

        public string? Name { get; init; }

        public RegistryValueKind Type { get; init; }

        public object? Value { get; init; }

        public override string? ToString()
        {
            if (Value is null)
            {
                return string.Empty;
            }

            return Type switch
            {
                RegistryValueKind.Binary => BitConverter.ToString((byte[])Value),
                RegistryValueKind.MultiString => string.Join(" ", (string[])Value),
                _ => Value.ToString(),
            };
        }
    }
}
