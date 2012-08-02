/*

== Definition: dhcp::shared-network
Creates a shared-network

Arguments:
  *$subnets* : subnet list to be included in the shared-network

Warnings:
- subnets must exists
- subnets must have $is_shared set to true (default is false)

*/
define dhcp::shared-network($ensure=present, $subnets=[]) {
  include dhcp::params
  concat::fragment {"shared-${name}":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => template("dhcp/shared-network.erb"),
    require => Dhcp::Subnet[$subnets],
  }
}
