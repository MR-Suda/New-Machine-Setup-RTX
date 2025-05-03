# 🚀 RTX Kali Auto Setup Script

A fully automated post-installation setup script for fresh **Kali Linux** installations, designed for **RTX Red Team** students and penetration testers who want a fast, stylish, and functional environment.

> 🛠️ **Version:** 1.2  
> 🧑‍💻 **Author:** [David] & [MR-Suda](https://github.com/MR-Suda)  
> 🎯 **Target OS:** Kali Linux (VM or Bare Metal)  
> 🖥️ **Desktop Environment:** XFCE + LightDM

---

## 📦 Features

✅ Stylized **RTX terminal banner** using `figlet`  
✅ Smart update & upgrade prompts  
✅ Installs **Geany**, `xclip`, `feh`, and other daily tools  
✅ Applies a custom **desktop wallpaper**  
✅ Applies a matching **lock screen wallpaper** via LightDM  
✅ Forces `numlock` to be enabled on login  
✅ Auto-configures `.zshrc` alias `xc` → clipboard copy shortcut  
✅ Ends with an interactive **countdown reboot**

---

## 📷 Screenshots

> ![RTX Banner Preview](https://github.com/MR-Suda/New-Machine-Setup-RTX/blob/main/Desktop_Wallpaper.png)

---

## ⚙️ Requirements

- A fresh Kali installation (tested with [official VMware image](https://www.kali.org/get-kali/#kali-virtual-machines))
- Must be run **as root** or using `sudo`
- Internet connection

---

## 📥 Installation

```bash
git clone https://github.com/MR-Suda/New-Machine-Setup-RTX.git
cd New-Machine-Setup-RTX
sudo bash setup.sh
