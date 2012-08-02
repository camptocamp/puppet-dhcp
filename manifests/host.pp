# = Definition: dhcp::host
#
# Create dhcp configuration for a host
#
# Arguments:
# *$mac*:           host MAC address (mandatory)
# *$subnet*:        subnet in which we want to add this host
# *$fixed_address*: host fixed address (if not set, takes $name)
#
#
define dhcp::host (
  $mac,
  $subnet,
  $ensure        = present,
  $fixed_address = false,
  $options       = false
) {

  include dhcp::params

  concat::fragment {"dhcp.host.${name}":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
    content => template('dhcp/host.conf.erb'),
    notify  => Service['dhcpd'],
  }

}
