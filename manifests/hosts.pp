# = Definition: dhcp::hosts
#
# Creates a dhcp configuration for given hosts
#
# Arguments
# $template:  dhcp host template - default: 'dhcp/host.conf.erb'
# $global_options: global options for the whole bunch of hosts.
#                  you may override it per host, setting the host "options"
#                  directly in the hash.
# $subnet:    targeted subnet
# $hash_data: hash containing data - default form:
#      {
#        <host1>         => {
#          options       => false,
#          fixed_address => false,
#          interfaces    => {
#            eth0        => 'mac-address',
#            eth1        => 'mac-address',
#            wlan0       => 'mac-address',
#            wlan1       => 'mac-address',
#            …,
#          }
#        },
#        <host2>         => {
#          options       => false,
#          fixed_address => false,
#          interfaces    => {
#            eth0        => 'mac-address',
#            eth1        => 'mac-address',
#            wlan0       => 'mac-address',
#            wlan1       => 'mac-address',
#            …,
#          }
#        },
#        …,
#      }
#
define dhcp::hosts (
  $hash_data,
  $subnet,
  $global_options = false,
  $template = 'dhcp/host.conf.erb',
) {

  include dhcp::params

  concat::fragment {"dhcp.host.${name}":
    target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
    content => template($template),
    notify  => Service['dhcpd'],
  }
}
