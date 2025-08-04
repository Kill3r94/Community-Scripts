<#
.SYNOPSIS
    Silently uninstalls Adobe Creative Cloud applications or lists installed products using the Adobe Uninstaller.

.DESCRIPTION
    This script runs the Adobe Creative Cloud Uninstaller with specified parameters to silently uninstall one or more Adobe products,
    uninstall all products, or list installed products. It supports a comma-separated list of product codes (e.g., PHSP#25.0 for Photoshop 2024),
    an option to uninstall all products, and listing installed products in CSV, table, or XML format.

.PARAMETER Products
    A comma-separated list of product codes and versions (e.g., "PHSP#26.0,ILST#28.0").
    Mutually exclusive with All and List parameters.
	Full list of SAP codes can be found here: https://helpx.adobe.com/enterprise/kb/adobe-cc-app-base-versions.html
	Does not support the removal of the Adobe CC installer (KCCC).

.PARAMETER All
    Silently uninstalls all Adobe products using the bundled AdobeUninstaller.exe. This includes the Adobe Creative Cloud Installer.
    Mutually exclusive with Products and List parameters. 

.PARAMETER List
    If specified, lists all installed Adobe products without performing uninstallation.
    Mutually exclusive with Products and All parameters.

.PARAMETER Format
    Specifies the output format for the -List command. Valid values are 'table', or 'xml'.
    Default is 'table'. If not specified, list output is saved as a .log file in SYSTEM Temp.

.PARAMETER SkipNotInstalled
    If specified, includes the -skipNotInstalled flag to ignore invalid or uninstalled product codes.

.PARAMETER UninstallerPath
    The path to the AdobeUninstaller.exe executable.
    Default is the script's directory ($PSScriptRoot\AdobeUninstaller.exe).

.PARAMETER uninstallConfigPath
    The path to an XML file containing uninstallation configurations to be passed directly to AdobeUninstaller.exe.
    The file must be in the same directory as AdobeUninstaller.exe or a relative path from that directory.
    Mutually exclusive with -All and -List parameters.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0,ILST#28.0" -SkipNotInstalled
    Silently uninstalls Photoshop 2024 and Illustrator 2024 using the bundled AdobeUninstaller.exe, skipping uninstalled products.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -All
    Silently uninstalls all Adobe products using the bundled AdobeUninstaller.exe. This includes the Adobe Creative Cloud Installer.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -List
    Lists all installed Adobe products in table format, logged to C:\Windows\Temp\Uninstall-AdobeCCProducts.log.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -List -Format "xml"
    Lists all installed Adobe products in XML format, saving output to C:\Windows\Temp\AdobeCCProductListOutput.xml.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0" -UninstallerPath "C:\Tools\AdobeUninstaller.exe"
    Silently uninstalls Photoshop 2024 using a custom uninstaller path.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml" -SkipNotInstalled
    Passes AdobeCCProductListOutput.xml to AdobeUninstaller.exe for product removal, skipping uninstalled products.

.NOTES
    - Requires administrative privileges. Can be used as a Pre-Install or Pre-Uninstall script with PMPC applications. 
    - By default, assumes AdobeUninstaller.exe is in the same directory as the script.
    - Log file and list output (if applicable) are saved in C:\Windows\Temp with a single log file (Uninstall-AdobeCCProducts.log).
    - The -All, -Products, -List, and -uninstallConfigPath parameters are mutually exclusive.
    - The -Format parameter is only used with -List.
#>

param (
    [Parameter(Mandatory = $false, HelpMessage = "Comma-separated list of product codes and versions (e.g., PHSP#26.0,ILST#28.0)")]
    [string]$Products,

    [Parameter(Mandatory = $false, HelpMessage = "Uninstall all Adobe products")]
    [switch]$All,

    [Parameter(Mandatory = $false, HelpMessage = "List installed Adobe products")]
    [switch]$List,

    [Parameter(Mandatory = $false, HelpMessage = "Output format for -List command (table or xml)")]
    [ValidateSet("table", "xml")]
    [string]$Format = "table",

    [Parameter(Mandatory = $false, HelpMessage = "Skip uninstalled products")]
    [switch]$SkipNotInstalled,

    [Parameter(Mandatory = $false, HelpMessage = "Path to AdobeUninstaller.exe")]
    [string]$UninstallerPath = "$PSScriptRoot\AdobeUninstaller.exe",

    [Parameter(Mandatory = $false, HelpMessage = "Path to an XML file containing uninstallation configurations")]
    [string]$uninstallConfigPath
)

# Initialize logging
$logFile = "$env:SystemRoot\Temp\Uninstall-AdobeCCProducts.log"
$listOutputFile = "$env:SystemRoot\Temp\AdobeCCProductListOutput.xml"
function Write-Log {
    param ([string]$Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Output $logMessage | Out-File -FilePath $logFile -Append
    Write-Host $logMessage
}

# Validate and resolve UninstallerPath
Write-Log "Resolving AdobeUninstaller.exe path: Initial value = $UninstallerPath"
if (-not (Test-Path $UninstallerPath)) {
    # Try resolving the path relative to the script directory explicitly
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

# Validate uninstallConfigPath if provided
if ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
    Write-Log "Processing uninstallConfigPath: $uninstallConfigPath"
    $configFullPath = Join-Path -Path $PSScriptRoot -ChildPath $uninstallConfigPath
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
} # Closing brace for the outer if block

# Validate parameter combinations
Write-Log "Validating parameter combinations"
if ($All -and ($Products -or $List -or $PSBoundParameters.ContainsKey('uninstallConfigPath'))) {
    Write-Log "ERROR: The -All parameter cannot be used with -Products, -List, or -uninstallConfigPath"
    exit 1
}
if ($List -and ($Products -or $All -or $PSBoundParameters.ContainsKey('uninstallConfigPath'))) {
    Write-Log "ERROR: The -List parameter cannot be used with -Products, -All, or -uninstallConfigPath"
    exit 1
}
if (($PSBoundParameters.ContainsKey('uninstallConfigPath') -and ($Products -or $All -or $List))) {
    Write-Log "ERROR: The -uninstallConfigPath parameter cannot be used with -Products, -All, or -List"
    exit 1
}
if ((-not $All -and -not $List -and -not $PSBoundParameters.ContainsKey('uninstallConfigPath') -and [string]::IsNullOrWhiteSpace($Products))) {
    Write-Log "ERROR: At least one of -Products, -All, -List, or -uninstallConfigPath must be specified"
    exit 1
}
if ($PSBoundParameters.ContainsKey('Format') -and -not $List) {
    Write-Log "ERROR: The -Format parameter can only be used with -List"
    exit 1
}

# Build the command arguments
$arguments = @()
if ($List) {
    $arguments += "--list"
    $arguments += "--format=$Format"
} elseif ($All) {
    $arguments += "--all"
} elseif ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
    $arguments += "--uninstallConfigPath=$configFullPath"
    if ($SkipNotInstalled) {
        $arguments += "--skipNotInstalled"
    }
} else {
    Write-Log "Validating Products parameter: $Products"
    if ([string]::IsNullOrWhiteSpace($Products)) {
        Write-Log "ERROR: Products parameter cannot be empty when using -Products"
        exit 1
    }
    $arguments += "--products=$Products"
    if ($SkipNotInstalled) {
        $arguments += "--skipNotInstalled"
    }
}

# Log the command to be executed
Write-Log "Executing command: $UninstallerPath $arguments"

# Run the uninstaller
try {
    if ($List) {
        # For -List, capture output and handle based on format
        $output = & $UninstallerPath $arguments 2>$null
        if ($LASTEXITCODE -eq 0) {
            if ($Format -eq "xml") {
                # Filter out the exit message and keep only XML content
                $xmlContent = $output | Where-Object { $_ -match "^<.*" } | Out-String
                $xmlContent = $xmlContent.Trim()
                if ($xmlContent) {
                    $xmlContent | Out-File -FilePath $listOutputFile -Encoding UTF8
                    Write-Log "List of installed products saved to $listOutputFile"
                } else {
                    Write-Log "WARNING: No XML content detected in output"
                    # Save an empty XML file to avoid breaking the process
                    "<UninstallXML/>" | Out-File -FilePath $listOutputFile -Encoding UTF8
                }
            } else {
                # Default to table format, log to console and log file
                $output | ForEach-Object { Write-Log $_ }
            }
            # Log the exit message separately
            $exitMessage = $output | Where-Object { $_ -match "AdobeUninstaller exiting with Return Code" }
            if ($exitMessage) {
                Write-Log $exitMessage
            }
        } else {
            Write-Log "ERROR: Failed to list products with exit code $LASTEXITCODE"
            exit $LASTEXITCODE
        }
    } else {
        # For uninstall operations
        $process = Start-Process -FilePath $UninstallerPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            if ($All) {
                $target = "all products"
            } elseif ($PSBoundParameters.ContainsKey('uninstallConfigPath')) {
                $target = "products in $configFullPath"
            } else {
                $target = "products: $Products"
            }
            Write-Log "Uninstallation completed successfully for $target"
        } else {
            Write-Log "ERROR: Uninstallation failed with exit code $($process.ExitCode)"
        }
    }
} catch {
    Write-Log "ERROR: Failed to execute uninstaller. Exception: $($_.Exception.Message)"
    exit 1
}


Write-Log "Script execution completed"