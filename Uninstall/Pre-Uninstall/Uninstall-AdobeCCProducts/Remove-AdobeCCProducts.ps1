<#
.SYNOPSIS
    Silently uninstalls Adobe Creative Cloud applications or lists installed products using the Adobe Uninstaller.

.DESCRIPTION
    This script runs the Adobe Creative Cloud Uninstaller with specified parameters to silently uninstall one or more Adobe products,
    uninstall all products, or list installed products. It supports a comma-separated list of product codes (e.g., PHSP#25.0 for Photoshop 2024),
    an option to uninstall all products, and listing installed products in CSV, table, or XML format.

.PARAMETER Products
    A comma-separated list of product codes and versions (e.g., "PHSP#25.0,ILST#28.0").
    Mutually exclusive with All and List parameters.
	Full list of SAP codes can be found here: https://helpx.adobe.com/enterprise/kb/adobe-cc-app-base-versions.html

.PARAMETER All
    If specified, uninstalls all installed Adobe products.
    Mutually exclusive with Products and List parameters.

.PARAMETER List
    If specified, lists all installed Adobe products without performing uninstallation.
    Mutually exclusive with Products and All parameters.

.PARAMETER Format
    Specifies the output format for the --list command. Valid values are 'csv', 'table', or 'xml'.
    Default is 'table'. If not specified, list output is saved as a .log file in SYSTEM Temp.

.PARAMETER SkipNotInstalled
    If specified, includes the --skipNotInstalled flag to ignore invalid or uninstalled product codes.

.PARAMETER UninstallerPath
    The path to the AdobeUninstaller.exe executable.
    Default is the script's directory ($PSScriptRoot\AdobeUninstaller.exe).

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0,ILST#28.0" -SkipNotInstalled
    Silently uninstalls Photoshop 2024 and Illustrator 2024 using the bundled AdobeUninstaller.exe, skipping uninstalled products.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -All
    Silently uninstalls all Adobe products using the bundled AdobeUninstaller.exe.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -List
    Lists all installed Adobe products in table format, saving output to C:\Windows\Temp with a .log extension.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -List -Format "xml"
    Lists all installed Adobe products in XML format, saving output to C:\Windows\Temp with a .xml extension.

.EXAMPLE
    .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0" -UninstallerPath "C:\Tools\AdobeUninstaller.exe"
    Silently uninstalls Photoshop 2024 using a custom uninstaller path.

.NOTES
    - Requires administrative privileges.
    - By default, assumes AdobeUninstaller.exe is in the same directory as the script.
    - Log file and list output (if applicable) are saved in C:\Windows\Temp with a timestamp.
    - The --all, --products, and --list parameters are mutually exclusive.
    - The --format parameter is only used with --list.
#>

param (
    [Parameter(Mandatory = $false, HelpMessage = "Comma-separated list of product codes and versions (e.g., PHSP#26.0,ILST#26.0)")]
    [string]$Products,

    [Parameter(Mandatory = $false, HelpMessage = "Uninstall all Adobe products")]
    [switch]$All,

    [Parameter(Mandatory = $false, HelpMessage = "List installed Adobe products")]
    [switch]$List,

    [Parameter(Mandatory = $false, HelpMessage = "Output format for --list command (csv, table, or xml)")]
    [ValidateSet("csv", "table", "xml")]
    [string]$Format = "table",

    [Parameter(Mandatory = $false, HelpMessage = "Skip uninstalled products")]
    [switch]$SkipNotInstalled,

    [Parameter(Mandatory = $false, HelpMessage = "Path to AdobeUninstaller.exe")]
    [string]$UninstallerPath = "$PSScriptRoot\AdobeUninstaller.exe"
)

# Initialize logging
$logFile = "$env:SystemRoot\Temp\AdobeUninstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$listOutputExtension = if ($PSBoundParameters.ContainsKey('Format')) { $Format } else { "log" }
$listOutputFile = "$env:SystemRoot\Temp\AdobeList_$(Get-Date -Format 'yyyyMMdd_HHmmss').$listOutputExtension"
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

# Validate parameter combinations
Write-Log "Validating parameter combinations"
if ($All -and ($Products -or $List)) {
    Write-Log "ERROR: The -All parameter cannot be used with -Products or -List"
    exit 1
}
if ($List -and $Products) {
    Write-Log "ERROR: The -List parameter cannot be used with -Products"
    exit 1
}
if ((-not $All -and -not $List -and [string]::IsNullOrWhiteSpace($Products))) {
    Write-Log "ERROR: At least one of -Products, -All, or -List must be specified"
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
        # For -List, capture output and save to file
        $process = Start-Process -FilePath $UninstallerPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait -RedirectStandardOutput $listOutputFile
        if ($process.ExitCode -eq 0) {
            Write-Log "List of installed products saved to $listOutputFile"
            # Display the output in console
            Get-Content $listOutputFile | ForEach-Object { Write-Host $_ }
        } else {
            Write-Log "ERROR: Failed to list products with exit code $($process.ExitCode)"
            exit $process.ExitCode
        }
    } else {
        # For uninstall operations
        $process = Start-Process -FilePath $UninstallerPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            if ($All) {
                $target = "all products"
            } else {
                $target = "products: $Products"
            }
            Write-Log "Uninstallation completed successfully for $target"
        } else {
            Write-Log "ERROR: Uninstallation failed with exit code $($process.ExitCode)"
            exit $process.ExitCode
        }
    }
} catch {
    Write-Log "ERROR: Failed to execute uninstaller. Exception: $($_.Exception.Message)"
    exit 1
}

# Clean up residual files (optional, uncomment if needed)
<#
Write-Log "Cleaning up residual files"
$residualPaths = @(
    "C:\Program Files\Adobe\Adobe Photoshop 2024",
    "C:\Program Files (x86)\Common Files\Adobe",
    "$env:APPDATA\Adobe"
)
foreach ($path in $residualPaths) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Removed residual path: $path"
    }
}
#>

Write-Log "Script execution completed"