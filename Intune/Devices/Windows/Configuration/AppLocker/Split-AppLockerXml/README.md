# Split-AppLockerXml

**Split-AppLockerXml** is a PowerShell script that splits a full AppLocker XML policy file into individual XML files based on `RuleCollection` types (Appx, Dll, Exe, Msi, Script). This makes it easier to manage or import specific rule types into tools like **Microsoft Intune**.

---

## 🧰 Features

- Automatically detects and processes a selected AppLocker XML file
- Splits it into separate XML files for each rule collection:
  - `Appx.xml`
  - `Dll.xml`
  - `Exe.xml`
  - `Msi.xml`
  - `Script.xml`
- Optional environment-based output folder structure (POC, PREPROD, PROD)
- Compatible with AppLocker policies exported from Group Policy or Intune

---

## 🧾 Usage

```powershell
.\Split-AppLockerXml.ps1
