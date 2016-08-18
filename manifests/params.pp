# Class: dhcp::params
#
# Do NOT include this class - it won't do anything.
# Set variables for names and paths
#
class dhcp::params {
  case $::osfamily {
    'RedHat': {
      $package_dhcpd = 'dhcp'
      $srv_dhcpd = 'dhcpd'
    }
    default: {
      $package_dhcpd = 'isc-dhcp-server'
      $srv_dhcpd = 'isc-dhcp-server'
    }
  }
  $config_dir = '/etc/dhcp'
  $service_pattern = '/usr/sbin/dhcpd'
  $server_template = "${module_name}/dhcpd.conf.debian.erb"
}
