# Remove-DuplicateShortcutOnDesktop

**Fixes duplicate desktop shortcuts caused by OneDrive Known Folder Move (KFM) during first user logon.**

When KFM is enabled, users may encounter duplicated shortcuts on their desktop (e.g., `Shortcut.lnk` and `Shortcut (1).lnk`). This PowerShell script automatically cleans them up in a safe and non-intrusive way.

---

## 🧰 What the Script Does

✔️ Creates a hidden `.cleaned` folder on the desktop
✔️ Detects duplicate `.lnk` (shortcut) files
✔️ Moves the *original* shortcut to `.cleaned` if it's broken (e.g., missing icon)
✔️ Renames the *duplicate* to the original name (keeping the working shortcut)
✔️ Moves any remaining duplicates to `.cleaned` (instead of deleting)

---

## ❓ Why Not Just Delete?

Deleting files from the desktop can prompt OneDrive sync warnings or even block the deletion.
To avoid disrupting the user experience, the script **moves duplicates to a hidden `.cleaned` folder** — making them recoverable if needed.

---

## 💻 Intune Deployment Settings

| Setting                              | Value     |
|--------------------------------------|-----------|
| Run this script using the logged on credentials | Yes       |
| Enforce script signature check       | No        |
| Run script in 64-bit PowerShell Host | No        |

---

## 🧱 About the `.exe` Version

A compiled `.exe` version of the script is included.
Using the executable prevents the PowerShell console window from appearing during execution — offering a **cleaner, invisible user experience**.

---

## 📁 Output Example

```
C:\Users\<Username>\Desktop\
├── MyApp.lnk
├── .cleaned\
│   ├── MyApp (1).lnk
│   └── BrokenShortcut.lnk
```

---

## ✅ Ideal Use Case

This script is intended for Windows environments where:

- OneDrive KFM is deployed via Intune or GPO
- Users are seeing cluttered desktops due to duplicate shortcuts
- You want a seamless cleanup without user disruption

---
