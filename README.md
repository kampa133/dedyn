# dedyn
## prerequisites
- curl
- dig
- hostname should not contain FQDN
## what does it do
- detects IPv6 adress and prefix
- detects public IPv4 
- if subdomain is not registered on dedyn.io:
  - registration of AAAA (A only updateds.sh [dualstack])
- if is registered:
  - check if existing AAAA record matches current prefix
  - no match
   - update
 
## todo
- merge both scripts (update_var.sh)
- vars to check $1
  - 4 only A
  - 6 only AAAA
  - d both
