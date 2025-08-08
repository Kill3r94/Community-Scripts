<#
.SYNOPSIS
    Silently uninstalls Adobe Creative Cloud applications, lists installed Adobe CC products, and can discover and remove leftover Adobe CC registry keys.

.DESCRIPTION
    This script runs the Adobe Creative Cloud Uninstaller to silently uninstall one or more Adobe products, uninstall all Adobe CC products, or list installed products.
    It supports a comma-separated list of product codes (e.g., PHSP#25.0 for Photoshop 2024), uninstalling all products, or listing products in TABLE or XML format.
    The --uninstallConfigPath parameter passes an XML file to the uninstaller for product removal. The -uninstallAdobeCCApp parameter removes the Adobe Creative
    Cloud app using the Creative Cloud Uninstaller and can be combined with -Products, -uninstallConfigPath, or -RegKeyCleanUp to uninstall specific products or
    clean up registry keys. The -Discovery parameter lists registry keys related to Adobe Creative Cloud products that may need cleanup, and the -RegKeyCleanUp
    parameter removes those keys. The -List and -Discovery parameters can be used together to correlate installed products with leftover registry keys. The
    -RegKeyCleanUp parameter can be combined with -Products, -uninstallConfigPath, -All, or -uninstallAdobeCCApp to perform registry cleanup alongside uninstallation.

    CAUTION: The -RegKeyCleanUp parameter should ONLY be used when the intent is to completely clean up leftover registry keys for ALL Adobe Creative Cloud products.
    This action is destructive and may remove registry entries required for remaining Adobe products if used incorrectly. Ensure all targeted products are uninstalled
    before using -RegKeyCleanUp, or use it deliberately to wipe all Adobe CC registry traces.

    NOTE: The -uninstallAdobeCCApp parameter will fail if Adobe Creative Cloud products are not fully removed prior to its execution. Ensure all dependent Adobe CC
    products are uninstalled (via -Products, -uninstallConfigPath, or -All) before attempting to remove the Creative Cloud app.

.PARAMETER -Products
    A comma-separated list of product codes and versions (e.g., "PHSP#25.0,ILST#28.0") or SAP codes (e.g., "PHSP,ILST,APRO").
    Can be used with -List, -SkipNotInstalled, -uninstallAdobeCCApp, or -RegKeyCleanUp.
    SAP Codes can be referenced here: https://helpx.adobe.com/enterprise/kb/adobe-cc-app-base-versions.html

.PARAMETER -All
    Uninstalls all installed Adobe CC products. Can be used with -RegKeyCleanUp but is mutually exclusive with List and Discovery.

.PARAMETER -List
    Lists all installed Adobe CC products or specific products if used with -Products. Can be used with -Discovery but is mutually exclusive with All,
    uninstallConfigPath, uninstallAdobeCCApp, and RegKeyCleanUp.

.PARAMETER -Format
    Specifies the output format for the -List command. Valid values are 'table' or 'xml'. Default is 'table'.

.PARAMETER -SkipNotInstalled
    Allows the script to ignore products that are not installed when uninstalling specific products via -Products or -uninstallConfigPath.

.PARAMETER -UninstallerPath
    Path to AdobeUninstaller.exe. Default is the script's directory ($PSScriptRoot\AdobeUninstaller.exe).
    If the AdobeUninstaller.exe is not found at the specified path, the script will attempt to locate it in the script's directory.

.PARAMETER -uninstallConfigPath
    Path to an XML file containing uninstallation configurations. Must be in the same directory as AdobeUninstaller.exe or a relative/full path.
    Can be used with -uninstallAdobeCCApp or -RegKeyCleanUp but is mutually exclusive with List and Discovery.
    XML file can be 

.PARAMETER -uninstallAdobeCCApp
    Removes the Adobe Creative Cloud app using the Creative Cloud Uninstaller. Can be used with -Products, -uninstallConfigPath, or -RegKeyCleanUp.
    Mutually exclusive with -All, -List, and -Discovery.

.PARAMETER -Discovery
    Lists registry keys related to Adobe Creative Cloud products that may need cleanup, exporting to LeftoverAdobeCCRegKeys.csv.
    Can be used with -List but is mutually exclusive with -All, -uninstallConfigPath, -uninstallAdobeCCApp, and -RegKeyCleanUp.

.PARAMETER -RegKeyCleanUp
    Removes leftover Adobe Creative Cloud registry keys. Can be used with -Products, -uninstallConfigPath, -All, or -uninstallAdobeCCApp but is mutually
    exclusive with -List and -Discovery.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -Products "PHSP#25.0,ILST#28.0" -SkipNotInstalled
    Uninstalls Photoshop 2024 and Illustrator 2024, skipping uninstalled products.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -All
    Uninstalls all Adobe CC products and will remove the Adobe Creative Cloud Desktop Application.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -List -Products "PHSP,ILST" -Format "xml"
    Lists Photoshop and Illustrator in XML format, saved to C:\Windows\Temp\AdobeCCProductListOutput.xml.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml"
    Uninstalls products specified in AdobeCCProductListOutput.xml.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -Products "PHSP,ILST" -uninstallAdobeCCApp
    Uninstalls Photoshop and Illustrator, then removes the Adobe Creative Cloud app.
    Note: Ensure all Adobe CC products are uninstalled before using -uninstallAdobeCCApp.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -Discovery
    Lists leftover Adobe CC registry keys in LeftoverAdobeCCRegKeys.csv and logs to Uninstall-AdobeCCProducts.log.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -RegKeyCleanUp
    Removes leftover Adobe CC registry keys, logging to Uninstall-AdobeCCProducts.log.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -List -Format "XML" -Discovery
    Lists installed Adobe CC products and leftover registry keys, saving output to AdobeCCProductListOutput.xml (if XML format) and LeftoverAdobeCCRegKeys.csv.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -Products "PHSP#25.0" -RegKeyCleanUp
    Uninstalls Photoshop 2024 and removes leftover Adobe registry keys.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -All -RegKeyCleanUp
    Uninstalls all Adobe CC products and Adobe CC Desktop app, then removes leftover registry keys.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml" -uninstallAdobeCCApp
    Uninstalls products specified in AdobeCCProductListOutput.xml and removes the Adobe Creative Cloud app.

.EXAMPLE
    .\Uninstall-AdobeCCProducts.ps1 -uninstallAdobeCCApp -RegKeyCleanUp
    Removes the Adobe Creative Cloud app and cleans up leftover Adobe CC product registry keys.

.NOTES
    - Requires administrative privileges or deployment through SCCM, Intune, or similar tools.
    - Assumes AdobeUninstaller.exe is in the script's directory by default or bundled with the application package.
    - Log file is saved in C:\Windows\Temp\Uninstall-AdobeCCProducts.log.
    - Discovery output is saved in C:\Windows\Temp\LeftoverAdobeCCRegKeys.csv.
    - The -uninstallAdobeCCApp operation may fail if Adobe CC products are not fully uninstalled first.
    - Use the -RegKeyCleanUp parameter with caution, as it will remove registry keys for all Adobe CC products.
#>

param (
    [Parameter(Mandatory = $false, HelpMessage = "Comma-separated list of product codes and versions (e.g., PHSP#25.0,ILST#28.0) or SAP codes (e.g., PHSP,ILST,APRO)")]
    [string]$Products,

    [Parameter(Mandatory = $false, HelpMessage = "Uninstall all Adobe products")]
    [switch]$All,

    [Parameter(Mandatory = $false, HelpMessage = "List installed Adobe products")]
    [switch]$List,

    [Parameter(Mandatory = $false, HelpMessage = "Output format for --list command (table or xml)")]
    [ValidateSet("table", "xml")]
    [string]$Format = "table",

    [Parameter(Mandatory = $false, HelpMessage = "Skip uninstalled products")]
    [switch]$SkipNotInstalled,

    [Parameter(Mandatory = $false, HelpMessage = "Path to AdobeUninstaller.exe")]
    [string]$UninstallerPath = "$PSScriptRoot\AdobeUninstaller.exe",

    [Parameter(Mandatory = $false, HelpMessage = "Path to an XML file containing uninstallation configurations")]
    [string]$uninstallConfigPath,

    [Parameter(Mandatory = $false, HelpMessage = "Remove the Adobe Creative Cloud app using the Creative Cloud Uninstaller")]
    [switch]$uninstallAdobeCCApp,

    [Parameter(Mandatory = $false, HelpMessage = "List leftover Adobe CC registry keys")]
    [switch]$Discovery,

    [Parameter(Mandatory = $false, HelpMessage = "Remove leftover Adobe CC registry keys")]
    [switch]$RegKeyCleanUp
)

# Initialize logging
$logFile = "$env:SystemRoot\Temp\Uninstall-AdobeCCProducts.log"
$listOutputFile = "$env:SystemRoot\Temp\AdobeCCProductListOutput.xml"
$csvFile = "$env:SystemRoot\Temp\LeftoverAdobeCCRegKeys.csv"

function Write-Log {
    param (
        [string]$Message,
        [switch]$NoTimestamp
    )
    if ($NoTimestamp) {
        Write-Output $Message | Out-File -FilePath $logFile -Append
        Write-Host $Message
    } else {
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
        Write-Output $logMessage | Out-File -FilePath $logFile -Append
        Write-Host $logMessage
    }
}

# Validate parameter combinations
Write-Log "Validating parameter combinations"
if ($All -and ($List -or $Discovery)) {
    Write-Log "ERROR: The -All parameter cannot be used with -List or -Discovery"
    exit 1
}
if ($PSBoundParameters.ContainsKey('uninstallConfigPath') -and ($List -or $Discovery)) {
    Write-Log "ERROR: The -uninstallConfigPath parameter cannot be used with -List or -Discovery"
    exit 1
}
if ($uninstallAdobeCCApp -and ($List -or $Discovery)) {
    Write-Log "ERROR: The -uninstallAdobeCCApp parameter cannot be used with -List or -Discovery"
    exit 1
}
if ($List -and ($All -or $PSBoundParameters.ContainsKey('uninstallConfigPath') -or $uninstallAdobeCCApp -or $RegKeyCleanUp)) {
    Write-Log "ERROR: The -List parameter cannot be used with -All, -uninstallConfigPath, -uninstallAdobeCCApp, or -RegKeyCleanUp"
    exit 1
}
if ($Discovery -and ($All -or $PSBoundParameters.ContainsKey('uninstallConfigPath') -or $uninstallAdobeCCApp -or $RegKeyCleanUp)) {
    Write-Log "ERROR: The -Discovery parameter cannot be used with -All, -uninstallConfigPath, -uninstallAdobeCCApp, or -RegKeyCleanUp"
    exit 1
}
if ((-not $All -and -not $List -and -not $PSBoundParameters.ContainsKey('uninstallConfigPath') -and -not $uninstallAdobeCCApp -and -not $Discovery -and -not $RegKeyCleanUp -and [string]::IsNullOrWhiteSpace($Products))) {
    Write-Log "ERROR: At least one of -Products, -All, -List, -uninstallConfigPath, -uninstallAdobeCCApp, -Discovery, or -RegKeyCleanUp must be specified"
    exit 1
}
if ($PSBoundParameters.ContainsKey('Format') -and -not $List) {
    Write-Log "ERROR: The -Format parameter can only be used with -List"
    exit 1
}

# Validate and resolve UninstallerPath (only for uninstall/list operations)
if ($List -or $All -or $PSBoundParameters.ContainsKey('uninstallConfigPath') -or $uninstallAdobeCCApp -or (-not [string]::IsNullOrWhiteSpace($Products))) {
    Write-Log "Resolving AdobeUninstaller.exe path: Initial value = $UninstallerPath"
    if (-not (Test-Path $UninstallerPath)) {
        $resolvedPath = Join-Path -Path $PSScriptRoot -ChildPath "AdobeUninstaller.exe"
        Write-Log "Attempting to resolve path: $resolvedPath"
        if (Test-Path $resolvedPath) {
            $UninstallerPath = $resolvedPath
            Write-Log "Resolved path to: $UninstallerPath"
        } else {
            Write-Log "ERROR: AdobeUninstaller.exe not found at $resolvedPath"
            exit 1
        }
    } else {
        Write-Log "Verified path: $UninstallerPath"
    }
}

# Validate uninstallConfigPath if provided
if ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
    Write-Log "Processing uninstallConfigPath: $uninstallConfigPath"
    if ([System.IO.Path]::IsPathRooted($uninstallConfigPath)) {
        $configFullPath = $uninstallConfigPath
    } else {
        $configFullPath = Join-Path -Path $PSScriptRoot -ChildPath $uninstallConfigPath
    }
    Write-Log "Resolved config file path: $configFullPath"
    if (-not (Test-Path $configFullPath)) {
        Write-Log "ERROR: Config file not found at $configFullPath"
        exit 1
    }
    $fileExtension = [System.IO.Path]::GetExtension($configFullPath).ToLower()
    if ($fileExtension -ne ".xml") {
        Write-Log "ERROR: Config file must be XML (got $fileExtension)"
        exit 1
    }
}

# Function to process registry keys (used by both Discovery and RegKeyCleanUp)
function Invoke-RegistryKeyProcessing {
    param (
        [switch]$DiscoveryMode
    )
    $registryHives = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $discoveredKeys = @()

    Write-Log "Processing registry hives for Adobe Creative Cloud keys"
    foreach ($hive in $registryHives) {
        Write-Log "Processing registry hive: $hive"
        Write-Host "Processing registry hive: $hive"
        
        try {
            $keys = Get-ItemProperty -Path $hive -ErrorAction SilentlyContinue
            
            foreach ($key in $keys) {
                $removeKey = $false
                $keyPath = $key.PSPath
                $displayName = $key.DisplayName
                $version = $key.DisplayVersion
                $systemComponent = $key.SystemComponent
                $publisher = $key.Publisher
                $comments = $key.Comments
                
                # Normalize version string to handle formats like "1.0.0000"
                $normalizedVersion = $null
                if ($version) {
                    $versionClean = $version -replace '\.0{1,}$', '' -replace '\.0{1,}\.', '.'
                    if ([version]::TryParse($versionClean, [ref]$null)) {
                        $normalizedVersion = [version]$versionClean
                    } else {
                        Write-Log "Invalid version format for key $keyPath (DisplayName: $displayName, Version: $version)"
                        Write-Host "Invalid version format for key $keyPath (DisplayName: $displayName, Version: $version)"
                    }
                }
                
                # Check for DisplayName containing "Adobe*" or "Illustrator"
                if ($displayName -like "Adobe*" -or $displayName -like "*Illustrator*") {
                    $excludeKey = $false
                    
                    if ($normalizedVersion -and $normalizedVersion -gt ([version]"1.0.0")) {
                        $excludeKey = $true
                        Write-Log "Excluded key: $keyPath (DisplayName: $displayName, Version: $version, Reason: Version > 1.0.0)"
                        Write-Host "Excluded key: $keyPath (DisplayName: $displayName, Version: $version, Reason: Version > 1.0.0)"
                    }
                    
                    if ($systemComponent -eq 0) {
                        $excludeKey = $true
                        Write-Log "Excluded key: $keyPath (DisplayName: $displayName, Version: $version, Reason: SystemComponent = 0)"
                        Write-Host "Excluded key: $keyPath (DisplayName: $displayName, Version: $version, Reason: SystemComponent = 0)"
                    }
                    
                    if (-not $excludeKey) {
                        $removeKey = $true
                        $matchReason = "DisplayName contains 'Adobe*' or 'Illustrator', SystemComponent not 0, and no version > 1.0.0"
                    }
                }
                # Check original Adobe-specific criteria
                elseif ($displayName) {
                    if ($normalizedVersion -and $normalizedVersion -le ([version]"1.0.0")) {
                        if ($displayName -like "Adobe*") {
                            if ($systemComponent -eq 1) {
                                $removeKey = $true
                                $matchReason = "Adobe* DisplayName, Version <= 1.0.0, SystemComponent = 1"
                            }
                        }
                        elseif ($publisher -eq "Adobe Systems Incorporated" -and 
                               $comments -like "*This package is created by Creative Cloud Packager*" -and 
                               $systemComponent -eq 1) {
                            $removeKey = $true
                            $matchReason = "Publisher = Adobe Systems Incorporated, Comments contains Creative Cloud Packager, Version <= 1.0.0, SystemComponent = 1"
                        }
                    }
                }
                
                if ($removeKey) {
                    $keyInfo = [PSCustomObject]@{
                        RegistryPath     = $keyPath
                        DisplayName      = $displayName
                        DisplayVersion   = $version
                        SystemComponent  = $systemComponent
                        Publisher        = $publisher
                        Comments         = $comments
                        MatchReason      = $matchReason
                    }
                    
                    $discoveredKeys += $keyInfo
                    
                    if ($DiscoveryMode) {
                        Write-Log "Discovered matching key: $keyPath (DisplayName: $displayName, Version: $version, Reason: $matchReason)"
                        Write-Host "Discovered matching key:"
                        Write-Host "  Registry Path: $keyPath"
                        Write-Host "  Display Name: $displayName"
                        Write-Host "  Version: $version"
                        Write-Host "  System Component: $systemComponent"
                        Write-Host "  Publisher: $publisher"
                        Write-Host "  Comments: $comments"
                        Write-Host "  Match Reason: $matchReason"
                        Write-Host "------------------------"
                    } else {
                        try {
                            Write-Log "Removing registry key: $keyPath (DisplayName: $displayName, Version: $version, Reason: $matchReason)"
                            Write-Host "Removing registry key:"
                            Write-Host "  Registry Path: $keyPath"
                            Write-Host "  Display Name: $displayName"
                            Write-Host "  Version: $version"
                            Write-Host "  System Component: $systemComponent"
                            Write-Host "  Publisher: $publisher"
                            Write-Host "  Comments: $comments"
                            Write-Host "  Match Reason: $matchReason"
                            Write-Host "------------------------"
                            
                            Remove-Item -Path $keyPath -Force -ErrorAction Stop
                            
                            Write-Log "Successfully removed registry key: $keyPath"
                            Write-Host "Successfully removed registry key: $keyPath"
                        } catch {
                            Write-Log "Error removing registry key $keyPath : $($_.Exception.Message)"
                            Write-Host "Error removing registry key $keyPath : $($_.Exception.Message)"
                        }
                    }
                }
            }
        } catch {
            Write-Log "Error processing hive $hive : $($_.Exception.Message)"
            Write-Host "Error processing hive $hive : $($_.Exception.Message)"
        }
    }

    # Export to CSV in Discovery mode
    if ($DiscoveryMode -and $discoveredKeys.Count -gt 0) {
        try {
            $discoveredKeys | Export-Csv -Path $csvFile -NoTypeInformation
            Write-Log "Exported discovered keys to CSV: $csvFile"
            Write-Host "Exported discovered keys to CSV: $csvFile"
        } catch {
            Write-Log "Error exporting to CSV: $($_.Exception.Message)"
            Write-Host "Error exporting to CSV: $($_.Exception.Message)"
        }
    } elseif ($DiscoveryMode -and $discoveredKeys.Count -eq 0) {
        Write-Log "No matching registry keys found for export."
        Write-Host "No matching registry keys found."
    }

    return $discoveredKeys.Count
}

# Main execution logic
try {
    # Handle -List and/or -Discovery
    if ($List -or $Discovery) {
        if ($List) {
            Write-Log "Running in List mode for installed Adobe products"
            $arguments = @("--list")
            if ($PSBoundParameters.ContainsKey('Format')) {
                $arguments += "--format=`"$Format`""
            }
            if (-not [string]::IsNullOrWhiteSpace($Products)) {
                $arguments += "--products=$Products"
            }
            Write-Log "Executing command: $UninstallerPath $arguments"
            $tempOutput = "$env:Temp\list_output.txt"
            $tempError = "$env:Temp\list_error.txt"
            $process = Start-Process -FilePath $UninstallerPath -ArgumentList $arguments -NoNewWindow -Wait -RedirectStandardOutput $tempOutput -RedirectStandardError $tempError -PassThru
            $output = Get-Content -Path $tempOutput -ErrorAction SilentlyContinue | Out-String
            #$errorOutput = Get-Content -Path $tempError -ErrorAction SilentlyContinue | Out-String
            if (Test-Path $tempOutput -PathType Leaf) {
                if ($Format -eq "xml") {
                    $xmlContent = $output -replace "AdobeUninstaller exiting with Return Code \(0\)", ""
                    if ($xmlContent -match "<UninstallXML>") {
                        $xmlContent | Out-File -FilePath $listOutputFile -Encoding UTF8
                        Write-Log "List of installed products saved to $listOutputFile"
                    } else {
                        Write-Log "WARNING: No valid XML content detected in output"
                        "<!-- Non-XML output: $xmlContent -->" | Out-File -FilePath $listOutputFile -Encoding UTF8
                    }
                } else {
                    $tableContent = $output -split "`n" | Where-Object { $_ -and $_ -notmatch "AdobeUninstaller exiting with Return Code" }
                    $tableContent -join "`n" | Write-Log -NoTimestamp
                    $exitMessage = $output | Where-Object { $_ -match "AdobeUninstaller exiting with Return Code" }
                    if ($exitMessage) {
                        Write-Log $exitMessage
                    }
                }
            } else {
                Write-Log "ERROR: Temporary output file $tempOutput not found"
            }
            Remove-Item -Path $tempOutput -ErrorAction SilentlyContinue
            Remove-Item -Path $tempError -ErrorAction SilentlyContinue
        }
        if ($Discovery) {
            Write-Log "Running in Discovery mode for Adobe registry keys"
            $keyCount = Invoke-RegistryKeyProcessing -DiscoveryMode
            Write-Log "Discovery completed. Total keys found: $keyCount"
            Write-Host "Discovery completed. Total keys found: $keyCount"
        }
    } else {
        # Handle uninstall and/or registry cleanup operations
        $arguments = @()
        if ($All) {
            $arguments += "--all"
        } elseif ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
            $arguments += "--uninstallConfigPath=$configFullPath"
            if ($SkipNotInstalled) {
                $arguments += "--skipNotInstalled"
            }
        } elseif (-not [string]::IsNullOrWhiteSpace($Products)) {
            Write-Log "Validating Products parameter: $Products"
            $arguments += "--products=$Products"
            if ($SkipNotInstalled) {
                $arguments += "--skipNotInstalled"
            }
        }

        # Log the command to be executed
        if ($arguments.Count -gt 0) {
            Write-Log "Executing command: $UninstallerPath $arguments"
        }
        if ($uninstallAdobeCCApp) {
            Write-Log "Executing Creative Cloud Uninstaller: C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\Creative Cloud Uninstaller.exe -u"
        }

        # Run the uninstaller if applicable
        if ($All -or $PSBoundParameters.ContainsKey('uninstallConfigPath') -or (-not [string]::IsNullOrWhiteSpace($Products))) {
            if (-not [string]::IsNullOrWhiteSpace($Products) -or $All -or $PSBoundParameters.ContainsKey('uninstallConfigPath')) {
                $process = Start-Process -FilePath $UninstallerPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
                if ($process.ExitCode -eq 0) {
                    if ($All) {
                        Write-Log "Uninstallation completed successfully for all products"
                    } elseif ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
                        Write-Log "Uninstallation completed successfully for products in $configFullPath"
                    } else {
                        Write-Log "Uninstallation completed successfully for products: $Products"
                    }
                } else {
                    if ($All) {
                        Write-Log "ERROR: Uninstallation failed with exit code $($process.ExitCode) for all products"
                    } elseif ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
                        Write-Log "ERROR: Uninstallation failed with exit code $($process.ExitCode) for products in $configFullPath"
                    } else {
                        Write-Log "ERROR: Uninstallation failed with exit code $($process.ExitCode) for products: $Products"
                    }
                }
            }
        }

        # Run Creative Cloud Uninstaller if requested
        if ($uninstallAdobeCCApp) {
            $ccUninstallerPath = "C:\Program Files (x86)\Adobe\Adobe Creative Cloud\Utils\Creative Cloud Uninstaller.exe"
            Write-Log "Checking for Creative Cloud Uninstaller at: $ccUninstallerPath"
            if (Test-Path $ccUninstallerPath) {
                Write-Log "Executing Creative Cloud Uninstaller with -u parameter"
                $tempOutput = "$env:Temp\cc_uninstall_output.txt"
                $process = Start-Process -FilePath $ccUninstallerPath -ArgumentList "-u" -NoNewWindow -Wait -RedirectStandardOutput $tempOutput -PassThru
                $output = Get-Content -Path $tempOutput -ErrorAction SilentlyContinue | Out-String
                if ($process.ExitCode -eq 0) {
                    if ($output) {
                        $output.Trim() | ForEach-Object { Write-Log "CC Uninstaller Output: $_" }
                    } else {
                        Write-Log "INFO: Creative Cloud Uninstaller completed with no redirected output"
                    }
                } else {
                    Write-Log "ERROR: Creative Cloud Uninstaller failed with exit code $($process.ExitCode)"
                    if ($output) {
                        $output.Trim() | ForEach-Object { Write-Log "CC Uninstaller Error Output: $_" }
                    }
                }
                Remove-Item -Path $tempOutput -ErrorAction SilentlyContinue
            } else {
                $alternativePaths = @(
                    "C:\Program Files\Adobe\Adobe Creative Cloud\Utils\Creative Cloud Uninstaller.exe",
                    "C:\Program Files (x86)\Common Files\Adobe\Creative Cloud Uninstaller.exe"
                )
                $foundPath = $alternativePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
                if ($foundPath) {
                    $ccUninstallerPath = $foundPath
                    Write-Log "Found Creative Cloud Uninstaller at alternative path: $ccUninstallerPath"
                    $tempOutput = "$env:Temp\cc_uninstall_output.txt"
                    $process = Start-Process -FilePath $ccUninstallerPath -ArgumentList "-u" -NoNewWindow -Wait -RedirectStandardOutput $tempOutput -PassThru
                    $output = Get-Content -Path $tempOutput -ErrorAction SilentlyContinue | Out-String
                    if ($process.ExitCode -eq 0) {
                        if ($output) {
                            $output.Trim() | ForEach-Object { Write-Log "CC Uninstaller Output: $_" }
                        } else {
                            Write-Log "INFO: Creative Cloud Uninstaller completed with no redirected output"
                        }
                    } else {
                        Write-Log "ERROR: Creative Cloud Uninstaller failed with exit code $($process.ExitCode)"
                        if ($output) {
                            $output.Trim() | ForEach-Object { Write-Log "CC Uninstaller Error Output: $_" }
                        }
                    }
                    Remove-Item -Path $tempOutput -ErrorAction SilentlyContinue
                } else {
                    Write-Log "ERROR: Creative Cloud Uninstaller not found at any known location"
                }
            }
        }

        # Perform registry cleanup if requested
        if ($RegKeyCleanUp) {
            Write-Log "Running registry key cleanup for Adobe Creative Cloud"
            $keyCount = Invoke-RegistryKeyProcessing
            Write-Log "Registry cleanup completed. Total keys processed: $keyCount"
            Write-Host "Registry cleanup completed. Total keys processed: $keyCount"
        }
    }
} catch {
    Write-Log "ERROR: Failed to execute operation. Exception: $($_.Exception.Message)"
    exit 1
} finally {
    Write-Log "Script execution completed"
}