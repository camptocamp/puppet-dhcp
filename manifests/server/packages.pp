# Class: dhcp::server::packages
#
# Install the DHCP server
#
class dhcp::server::packages {
  include ::dhcp::params

  validate_string($dhcp::params::package_dhcpd)
  validate_re($dhcp::params::package_dhcpd, '^\S+$')

  package {'dhcp-server':
    ensure => present,
    name   => $dhcp::params::package_dhcpd,
  }
}
