#!/bin/bash

# SELinux Security Scanning Tool
# Purpose: Identify common misconfigurations that attackers might exploit

echo -e "\n\033[1;34m=== SELinux Security Learning Tool ===\033[0m"
echo "This script helps you find potential SELinux weaknesses."
echo "Use this knowledge to secure your system, not exploit it."
echo "------------------------------------------------------"

# 1. Check if SELinux is enabled
if ! command -v sestatus &> /dev/null; then
    echo -e "\033[1;31m[!] SELinux not installed. Install with: sudo dnf install selinux-policy\033[0m"
    exit 1
fi

SELINUX_MODE=$(getenforce)
echo -e "\033[1;33m[+] Current SELinux Mode: $SELINUX_MODE\033[0m"

if [ "$SELINUX_MODE" == "Disabled" ]; then
    echo -e "\033[1;31m[!] WARNING: SELinux is disabled (hackers could abuse this!)\033[0m"
    echo -e "    Secure it with: sudo setenforce 1 && sudo sed -i 's/SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config"
fi

# 2. Check for permissive domains (common misconfiguration)
echo -e "\n\033[1;35m[?] Checking for permissive domains (could allow bypasses):\033[0m"
semanage permissive -l

# 3. Look for overly permissive file contexts
echo -e "\n\033[1;35m[?] Checking high-risk file contexts (world-writable or unusual labels):\033[0m"
find / -xdev -type f -perm -0002 -context *:object_r:* -ls 2>/dev/null | head -n 10
echo -e "\033[1;33m[!] Any 'unconfined' or 'tmp_t' files here could be risky.\033[0m"

# 4. Check boolean settings (common attack surface)
echo -e "\n\033[1;35m[?] Reviewing SELinux booleans (hackers often abuse these):\033[0m"
getsebool -a | grep "on$"
echo -e "\033[1;33m[!] Booleans like 'httpd_anon_write' or 'nis_enabled' can weaken security.\033[0m"

# 5. Recent SELinux denials (indicate misconfigs)
echo -e "\n\033[1;35m[?] Recent SELinux denials (could reveal weaknesses):\033[0m"
ausearch -m avc -ts recent 2>/dev/null | tail -n 5
echo -e "\033[1;33m[!] Frequent denials might mean policies need tuning.\033[0m"

# 6. Check for unconfined processes
echo -e "\n\033[1;35m[?] Unconfined processes (no SELinux protection):\033[0m"
ps -eZ | grep unconfined
echo -e "\033[1;33m[!] Hackers target unconfined processes first!\033[0m"

# === How to Fix Issues ===
echo -e "\n\033[1;32m[+] How to Secure Your System:\033[0m"
echo "1. Set SELinux to enforcing: sudo setenforce 1"
echo "2. Audit policies: sudo audit2allow -a"
echo "3. Tighten booleans: sudo setsebool -P [boolean_name] off"
echo "4. Study SELinux: https://selinuxproject.org/page/Main_Page"

echo -e "\n\033[1;34m[+] Done. Use this info to HARDEN your system, not hack it!\033[0m"
