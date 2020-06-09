# dedyn

## prerequisites

- curl
- dig
- hostname should not contain FQDN

## what does it do

- detects IPv6 adress and prefix
- detects public IPv4 
- creates, updates and deletes A and AAAA records (delete = setting loopback adresses)
- updates only if neccessary
- option for SSHFP

## todo

- real deletion
- function_check_AAAA () could be better

## How to use it

- clone repo to folder ~/git
- create a file ~/git/dedyn/update.conf  with 2 lines: 
  - DOMAIN=xxx.dedyn.io
  - TOKEN=123456789123456789
- to update or create an A record for a host
  - bash ~/git/dedyn/update_var.sh 4
- to update or create an AAAA record for a host
  - bash ~/git/dedyn/update_var.sh 6
- to update or create an A and AAAA record for a host
  - bash ~/git/dedyn/update_var.sh d
- to "delete" a record for a host
  - bash ~/git/dedyn/update_var.sh x
- to create a SSHFP record for a host
  - bash ~/git/dedyn/update_var.sh s
- 4, 6 or d should be started via cron
  - " */11 * * * * bash ~/git/dedyn/update_var.sh 6 >> /tmp/dedyn 2>&1 & "