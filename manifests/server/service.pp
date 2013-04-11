class dhcp::server::service {
  include ::dhcp::params

  service {'dhcpd':
    ensure  => running,
    name    => $dhcp::params::srv_dhcpd,
    enable  => true,
    pattern => $dhcp::params::service_pattern,
  }
}
