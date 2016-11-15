# Definition: dhcp::shared-network
#
# Creates a shared-network
#
# Parameters:
#   ['subnets'] - An array of subnets to be included in the shared-network.
#
# Sample usage:
#   ::dhcp::shared_network { 'office':
#     subnets => ['192.168.1.0', '192.168.2.0'],
#   }
#
# Requires:
#   - puppetlabs/stdlib
#   - ripienaar/concat
#
# Warnings:
#   - subnets must exists
#   - subnets must have $is_shared set to true (default is false)
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

  if $ensure == 'present' {
    concat::fragment {"dhcp-shared-${name}":
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
      content => template("${module_name}/shared-network.erb"),
      require => Dhcp::Subnet[$subnets],
    }
  }

}
