# = Class: dhcp::params
#
# Do NOT include this class - it won't do anything.
# Set variables for names and paths
#
class dhcp::params {

  case $::operatingsystem {

    Debian: {
      $config_dir = $::lsbdistcodename? {
        lenny   => '/etc/dhcp3',
        squeeze => '/etc/dhcp',
      }

      $srv_dhcpd = $::lsbdistcodename? {
        lenny   => 'dhcp3-server',
        squeeze => 'isc-dhcp-server',
      }

      $service_pattern = $::lsbdistcodename? {
        lenny   => '/usr/sbin/dhcpd3',
        squeeze => '/usr/sbin/dhcpd',
      }

      $base_template = 'dhcp/dhcpd.conf.debian.erb'
    }

    default: {
      fail "${name} is not available for ${::operatingsystem}/${::lsbdistcodename}"
    }

  }
}
