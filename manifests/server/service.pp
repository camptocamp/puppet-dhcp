# Class: dhcp::server::service
#
# Manage the DHCP server service
#
class dhcp::server::service {
  include ::dhcp::params

  validate_string($dhcp::params::srv_dhcpd)
  validate_re($dhcp::params::srv_dhcpd, '^\S+$')
  validate_string($dhcp::params::service_pattern)
  validate_re($dhcp::params::service_pattern, '^\S+$')

  service {'dhcpd':
    ensure  => running,
    name    => $dhcp::params::srv_dhcpd,
    enable  => true,
    pattern => $dhcp::params::service_pattern,
  }
}
