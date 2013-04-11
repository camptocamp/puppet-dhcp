class dhcp::server::packages {
  include ::dhcp::params

  package {'dhcp-server':
    ensure => present,
    name   => $dhcp::params::srv_dhcpd,
  }
}
