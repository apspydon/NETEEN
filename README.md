# NETEEN — Educational Network & Captive Portal Lab (Bash)

> A hands-on Linux networking lab that demonstrates how Wi-Fi access points, DHCP, routing, and captive portals work — built as a personal learning project in Bash.

NETEEN is an **educational Linux networking project** designed to help students and beginners understand how real-world network infrastructure works under the hood.

It focuses on **learning**, not automation or real-world deployment.

---

## 🎓 What NETEEN Teaches

NETEEN was created to explore and understand:

### Linux & Networking
- Wireless interfaces and AP (access point) mode
- How `hostapd` creates Wi-Fi access points
- DHCP address assignment with `dnsmasq`
- Basic routing, NAT, and `iptables`
- How captive portals redirect traffic

### Bash Scripting
- Large Bash projects and structure
- Menu-driven terminal UI
- Multilingual interfaces
- Process management and cleanup
- Signal handling (`trap`, background jobs)

### Web Fundamentals
- Basic HTML/CSS captive portal pages
- PHP form handling
- How a captive portal login flow works

This project is intended as a **learning lab**, similar to what networking students build while studying system administration or cybersecurity fundamentals.

---

## ⚠️ Legal & Ethical Notice (Important)

NETEEN is **strictly educational** and must only be used:

- On networks you **own**
- In **private lab environments**
- With **explicit permission**
- With **dummy or test data only**

This project is **not intended for malicious use**.

If you do not have legal authorization to test a network, **do not use this software**.

The author and contributors assume **no responsibility for misuse**.

---

## 🧪 Tested Environment

- **Tested on:** Kali Linux  
- **Likely compatible with:** Debian-based Linux distributions  
  (Ubuntu, Debian, Parrot OS — advanced users)

Requirements:
- Wireless interface that supports AP mode
- `hostapd`
- `dnsmasq`
- `apache2`
- `php`
- `iw`

---

## 📦 Installation

```bash
git clone https://github.com/apspydon/NETEEN
cd NETEEN
chmod +x NETEEN.sh
sudo ./NETEEN.sh
