# == Definition: dhcp::shared-network
# Creates a shared-network
#
# Arguments:
#  *$subnets* : subnet list to be included in the shared-network
#
# Warnings:
#  - subnets must exists
#  - subnets must have $is_shared set to true (default is false)
#
define dhcp::shared_network(
  $ensure  = present,
  $subnets = [],
) {

  include ::dhcp::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_array($subnets)

  concat::fragment {"dhcp-shared-${name}":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => template("${module_name}/shared-network.erb"),
    require => Dhcp::Subnet[$subnets],
  }

}
