# Class: dhcp::server::packages
#
# Install the DHCP server
#
class dhcp::server::packages {
  include ::dhcp::params

  validate_string($dhcp::params::srv_dhcpd)
  validate_re($dhcp::params::srv_dhcpd, '^\S+$')

  package {'dhcp-server':
    ensure => present,
    name   => $dhcp::params::srv_dhcpd,
  }
}
