# Class: dhcp::params
#
# Do NOT include this class - it won't do anything.
# Set variables for names and paths
#
class dhcp::params {
  $config_dir = '/etc/dhcp'
  $srv_dhcpd = 'isc-dhcp-server'
  $service_pattern = '/usr/sbin/dhcpd'
  $server_template = "${module_name}/dhcpd.conf.debian.erb"
}
