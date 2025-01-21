dnszone            = "{domainname}"
unique_id          = "netbox"
dbname             = "ipam"
dbuser             = "ipam"
dbpassword         = "{password}" // This is not a good practice at all. The best option is to use randomly generated password
location           = "norwayeast"
db_sku_name        = "B_Standard_B1ms"
storage_tier       = "P4"
db_version         = "16"
purpose            = "stateful"
proxydnszone       = "{proxydnszonename}"
vnetipaddressrange = "10.10.2.0/23"
subnetlist         = ["10.10.2.0/28", "10.10.2.32/27"]
environment        = "test"


