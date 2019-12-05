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
## todo
- real deletion
- function_check_AAAA () could be better