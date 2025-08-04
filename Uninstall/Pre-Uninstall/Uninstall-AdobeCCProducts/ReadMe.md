# SYNOPSIS

Automates the uninstallation of Adobe Creative Cloud applications or lists installed products using the Adobe Uninstaller (`AdobeUninstaller.exe`). It is designed for enterprise use, including deployment via Microsoft Intune Win32 packages, SCCM Packages, and can be utilized as a PatchMyPC Pre-script. The script supports various parameters for flexible removal of Adobe CC products.

## DESCRIPTION

- **Purpose**: Silently uninstall specific Adobe Creative Cloud products, uninstall all products, or list installed products with customizable output formats.
- **Supported Formats**: CSV, Table, XML (for listing), and LOG (default for listing without format specification).
- **Logging**: Outputs are saved to `C:\Windows\Temp` with timestamps for auditing and troubleshooting.

## HOW TO USE THE SCRIPT

- **PatchMyPC Pre-Script**: The script can be utilized as a pre-script along with PatchMyPC Custom Adobe CC Applications to remove older versions of those prior to installing the updated version. 
- **Standalone**: The script can also be used outside of PatchMyPC products to remove any or all Adobe CC products.
- **AdobeUninstaller.exe**: Must be bundled with the script in the same directory. If you're including the script as a pre-script, then the AdobeUninstaller must be added to the package as an Additional or Extra File. The AdobeUninstaller can be downloaded from [The Adobe Admin Console](https://helpx.adobe.com/enterprise/using/uninstall-creative-cloud-products.html).


## SUPPORTED PARAMETERS

- **`-Products`** (String)
  - Description: Comma-separated list of product codes (e.g., `"PHSP#25.0,ILST#28.0"`). Mutually exclusive with `-All` and `-List`.
  - Default Value: (Required if `-All` and `-List` not used)

- **`-All`** (Switch)
  - Description: Uninstall all Adobe CC products. Mutually exclusive with `-Products` and `-List`.
  - Default Value: `$false`

- **`-List`** (Switch)
  - Description: List installed Adobe CC products without uninstallation. Will also show the SAP code for the installed products and version numbers.
    Mutually exclusive with `-Products` and `-All`.
  - Default Value: `$false`

- **`-Format`** (String)
  - Description: Output format for `-List` (valid values: `table`, `xml`). If not specified, output is saved as `.log`.
  - Default Value: `table`

- **`-SkipNotInstalled`** (Switch)
  - Description: Ignore invalid or uninstalled product codes.
  - Default Value: `$false`

- **`-UninstallerPath`** (String)
  - Description: Path to `AdobeUninstaller.exe`. Defaults to script directory.
  - Default Value: `$PSScriptRoot\AdobeUninstaller.exe`

- **`-uninstallConfigPath`** (String)
  - Descripttion: Path to an XML file containing uninstallation configurations to be passed directly to `AdobeUninstaller.exe`.
  - The file must be in the same directory as `AdobeUninstaller.exe` or a relative path from that directory.
  - Mutually exclusive with `-All` and `-List` parameters.


### Script Examples

**`.EXAMPLE:`**
   1. .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0,ILST#28.0" -SkipNotInstalled
    - Silently uninstalls Photoshop 2024 and Illustrator 2024 using the bundled AdobeUninstaller.exe, skipping uninstalled products.

**`.EXAMPLE:`**
   2. .\Remove-AdobeCCProducts.ps1 -All
    - Silently uninstalls all Adobe products using the bundled AdobeUninstaller.exe.

**`.EXAMPLE:`**
   3. .\Remove-AdobeCCProducts.ps1 -List
    - Lists all installed Adobe products in table format, saving output to C:\Windows\Temp with a .log extension.

**`.EXAMPLE:`**
   4. .\Remove-AdobeCCProducts.ps1 -List -Format "xml"
    - Lists all installed Adobe products in XML format, saving output to C:\Windows\Temp with a .xml extension.

**`.EXAMPLE:`**
   5. .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0" -UninstallerPath "C:\Tools\AdobeUninstaller.exe"
    - Silently uninstalls Photoshop 2024 using a custom uninstaller path.

**`.EXAMPLE:`**
   6. .\Remove-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml" -SkipNotInstalled
    - Passes AdobeCCProductListOutput.xml to AdobeUninstaller.exe for product removal, skipping uninstalled products.
