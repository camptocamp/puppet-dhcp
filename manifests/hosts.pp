# = Definition: dhcp::hosts
#
# Creates a dhcp configuration for given hosts
#
# Arguments
# $template:  dhcp host template - default: 'dhcp/host.conf.erb'
# $subnet:    targeted subnet
# $data_hash: hash containing data - default form:
#      {
#        <host1>         => {
#          options       => false,
#          fixed_address => false,
#          eth0          => 'mac-address',
#          eth1          => 'mac-address',
#          …,
#          wlan0 => 'mac-address',
#          wlan1 => 'mac-address',
#          …,
#        },
#        <host2>         => {
#          options       => false,
#          fixed_address => false,
#          eth0          => 'mac-address',
#          eth1          => 'mac-address',
#          …,
#          wlan0 => 'mac-address',
#          wlan1 => 'mac-address',
#          …,
#          options => false,
#        },
#        …,
#      }
#
define dhcp::hosts (
  $data_hash,
  $subnet,
  $template = 'dhcp/host.conf.erb',
) {

  include dhcp::params

  concat::fragment {"dhcp.host.${name}":
    target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
    content => template($template),
    notify  => Service['dhcpd'],
  }
}
