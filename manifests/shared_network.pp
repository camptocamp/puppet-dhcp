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
  Enum['present', 'absent'] $ensure  = present,
  Array[Stdlib::Ipv4]       $subnets = [],
) {

  include ::dhcp::params

  if $ensure == 'present' {
    concat::fragment {"dhcp-shared-${name}":
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
      content => epp(
        "${module_name}/shared-network.epp",
        {
          name       => $name,
          subnets    => $subnets,
          config_dir => $::dhcp::params::config_dir,
        },
      ),
      require => Dhcp::Subnet[$subnets],
    }
  }

}
