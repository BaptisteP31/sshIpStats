#!/bin/bash

python_prog() {
    python3 - << EOF

def ip_list():
    ip = open("__ip.txt", "r")
    iplist = ip.readlines()              
    ip.close()
    return iplist

def ip_counter(iplist, ip):
    it = 0
    for i in iplist:
        if ip == i:
            it = it + 1
    return it

def is_in_list(list, item):
    for i in range(len(list)):
        if item == list[i]:
            return True
    return False

def clear_list(list):
    cleared_list = []
    for i in list:
        if is_in_list(cleared_list, i):
            continue
        else:
            cleared_list.append(i)
    return cleared_list


list = ip_list()
clear_list = clear_list(list)
it = 0
for i in clear_list:
    for j in list:
        if j == i:
            it = it +1
    print(i[:-2] + "," + str(it))

EOF
}

if [ "$EUID" != 0 ] #Ask for privileges
then
    echo "In order to work properly, this programm needs root privileges."
    sudo "$0" "$@"
    exit $?
fi

echo "Welcome to IP Stats v0.1"
echo "Grabbing the ip list ..."
cat /var/log/auth.log | grep Failed | grep root | awk -v RS='([0-9]+\\.){3}[0-9]+' 'RT{print RT}' > __ip.txt #output ip list to __ip.txt file
echo "Done!"


echo "Formating data..."
python_prog > sshIpStatsOutput.csv
echo "Done!"
echo "All formated data has been put in sshIpStatsOutput.csv"

read -p "Do you wanna remove the temp raw data ? [Y/n] " -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm __ip.txt
fi

echo "Thank you for using sshIpStats !"