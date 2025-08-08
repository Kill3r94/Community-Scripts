# Uninstall-AdobeCCProducts.ps1
# SYNOPSIS

Automates the uninstallation of Adobe Creative Cloud applications or lists installed products using the Adobe Uninstaller (`AdobeUninstaller.exe`). It is designed for enterprise use, including deployment via Microsoft Intune Win32 packages, SCCM Packages, and can be utilized as a PatchMyPC Pre-script. The script supports various parameters for flexible removal of Adobe CC products.

## DESCRIPTION

The purpose of this script is to provide a silent, clean and flexible method for removing specific and/or all Adobe Creative Cloud Applications. This script can also remove the Adobe Creative Cloud Desktop Application and supports removeal of any leftover registry keys from those Adobe CC products.

The script relies on the `AdobeUninstaller.exe` to perform its primary functions and will require the uninstaller to be included in the application package or script directory location. You can use the `-uninstallerPath` parameter to referece the `AdobeUninstaller.exe` from a different location on the client if needed. The `AdobeUninstaller.exe` can be downloaded from the [Adobe Admin Console](https://adminconsole.adobe.com/?promoid=12B9DRDF&mv=other).

The script also supports exporting the list of products as either a `table` or `xml` file format. The `xml` file can then be used to remove those listed products using the `-unintallConfigPath` parameter which passed the `xml` to the `AdobeUninstaller.exe` to perform the unisntallations.

Typically this script is best used with Adobe Creative Cloud custom apps built through the PatchMyPC cloud portal. This will help remove over versions (Photoshop 2024) when upgrading to a newer version (Photoshop 2025). However, this script can be ran locally on the client with local admin privledges. 

Logging is also supported with the script. All file exports, including logging, can be found in the SYSTEM temp folder: (`C:\Windows\Temp`).

## HOW TO USE THE SCRIPT

- **PatchMyPC Pre-Script**: The script can be utilized as a pre-script along with PatchMyPC Custom Adobe CC Applications to remove older versions of those prior to installing the updated version. 
- **Standalone**: The script can also be used outside of PatchMyPC products to remove any or all Adobe CC products.
- **AdobeUninstaller.exe**: Must be bundled with the script in the same directory. If you're including the script as a pre-script, then the AdobeUninstaller must be added to the package as an Additional or Extra File. The AdobeUninstaller can be downloaded from [The Adobe Admin Console](https://helpx.adobe.com/enterprise/using/uninstall-creative-cloud-products.html).
- **Addobe SAP Product Codes**: The `-Products` parameter requires the SAP product code to reference the product you wish to remove. A list of those SAP product codes can be found here: [SAP Product Codes](https://helpx.adobe.com/enterprise/kb/adobe-cc-app-base-versions.html).


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
  - AdobeUninstaller.exe`

- **`-uninstallConfigPath`** (String)
  - Descripttion: Path to an XML file containing uninstallation configurations to be passed directly to `AdobeUninstaller.exe`.
  - The file must be in the same directory as `AdobeUninstaller.exe` or a relative path from that directory.
  - Mutually exclusive with `-All` and `-List` parameters.
  - Default Value: `$PSScriptRoot\AdobeUninstaller.exe`

- **`-uninstallAdobeCCApp`** (Switch)
    - Removes the Adobe Creative Cloud app using the Creative Cloud Uninstaller. Can be used with `-Products`, `-uninstallConfigPath`, or `-RegKeyCleanUp`.
    - Mutually exclusive with `-All`, `-List`, and `-Discovery`.

- **`-Discovery`** (Switch)
    - Lists registry keys related to Adobe Creative Cloud products that may need cleanup, exporting to `LeftoverAdobeCCRegKeys.csv` in `C:\Windows\temp`.
    - Can be used with -List but is mutually exclusive with `-All`, `-uninstallConfigPath`, `-uninstallAdobeCCApp`, and `-RegKeyCleanUp`.

- **`-RegKeyCleanUp`** (Switch)
    -  Removes leftover Adobe Creative Cloud registry keys. Can be used with `-Products`, `-uninstallConfigPath`, `-All`, or `-uninstallAdobeCCApp`.
    - Mutually exclusive with `-List` and `-Discovery`.

    


## Examples

### Example 1: 
- Silently uninstalls Photoshop 2024 and Illustrator 2024 using the bundled `AdobeUninstaller.exe`, skipping uninstalled products.
```
.\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0,ILST#28.0" -SkipNotInstalled
```

### Example 2: 
- Silently uninstalls all Adobe CC products using the bundled AdobeUninstaller.exe.
```
.\Remove-AdobeCCProducts.ps1 -All
```

### Example 3: 
- Lists all installed Adobe CC products in table format, saving output to `C:\Windows\Temp` with a `.log` extension.
```
   .\Remove-AdobeCCProducts.ps1 -List
```   

### Exmaple 4:
 - Lists all installed Adobe CC products in XML format, saving output to `C:\Windows\Temp` with a `.xml` extension.
```
   .\Remove-AdobeCCProducts.ps1 -List -Format "xml"
```   
### Example 5: 
 - Silently uninstalls Photoshop 2024 using a custom uninstaller path.
```
 .\Remove-AdobeCCProducts.ps1 -Products "PHSP#25.0" -UninstallerPath "C:\Tools\AdobeUninstaller.exe"
```
### Example 6:
- Passes `AdobeCCProductListOutput.xml` to `AdobeUninstaller.exe` for product removal, skipping uninstalled products.
```
   .\Remove-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml" -SkipNotInstalled
```   
### Example 7:
- Uninstalls Photoshop and Illustrator, then removes the Adobe Creative Cloud app.

    >Please Note: Ensure all Adobe CC products are uninstalled before using -uninstallAdobeCCApp.
```
    .\Uninstall-AdobeCCProducts.ps1 -Products "PHSP,ILST" -uninstallAdobeCCApp
``` 

### Example 8: 
- Lists leftover Adobe CC registry keys in `LeftoverAdobeCCRegKeys.csv` and logs to `Uninstall-AdobeCCProducts.log`.
```
    .\Uninstall-AdobeCCProducts.ps1 -Discovery
```
    
### Example 9: 
- Removes leftover Adobe CC registry keys, logging to `Uninstall-AdobeCCProducts.log`.
```
    .\Uninstall-AdobeCCProducts.ps1 -RegKeyCleanUp
```   
### Example 10: 
- Lists installed Adobe CC products and leftover registry keys, saving output to `AdobeCCProductListOutput.xml` and `LeftoverAdobeCCRegKeys.csv`. Those files can be found in `C:\Windows\Temp`.
```
    .\Uninstall-AdobeCCProducts.ps1 -List -Format "XML" -Discovery
```
### Example 11: 
- Uninstalls Photoshop 2024 and removes leftover Adobe registry keys for all Adobe CC Products.
```
    .\Uninstall-AdobeCCProducts.ps1 -Products "PHSP#25.0" -RegKeyCleanUp
```      
### Example 12: 
- Uninstalls all Adobe CC products including the Adobe CC Desktop app, then removes leftover registry keys from those uninstallers.
```
    .\Uninstall-AdobeCCProducts.ps1 -All -RegKeyCleanUp
```
### Example 13: 
- Uninstalls products specified in `AdobeCCProductListOutput.xml` and removes the Adobe Creative Cloud app.
```
    .\Uninstall-AdobeCCProducts.ps1 -uninstallConfigPath "AdobeCCProductListOutput.xml" -uninstallAdobeCCApp
```
### Example 14: 
- Removes the Adobe Creative Cloud app and cleans up leftover Adobe CC product registry keys.

    > Please Note: All Adobe Creative Cloud apps need to be removed first prior to removing the Adobe CC Desktop app. 
```
    .\Uninstall-AdobeCCProducts.ps1 -uninstallAdobeCCApp -RegKeyCleanUp
```   