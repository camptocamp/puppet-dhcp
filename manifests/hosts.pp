# Definition: dhcp::hosts
#
# Creates a dhcp configuration for given hosts
#
# Arguments
# $template:  dhcp host template - default: 'dhcp/host.conf.erb'
# $global_options: an array of global options for the whole bunch of hosts.
#                  you may override it per host, setting the host "options"
#                  directly in the hash.
# $subnet:    targeted subnet
# $hash_data: hash containing data - default form:
#      {
#        <host1>         => {
#          options       => ['opt1', 'opt2'],
#          interfaces    => {
#            eth0        => 'mac-address',
#            eth1        => 'mac-address',
#            wlan0       => 'mac-address',
#            wlan1       => 'mac-address',
#            …,
#          }
#        },
#        <host2>         => {
#          fixed_address => 'foo.example.com',
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
  $ensure = present,
  $global_options = [],
  $template = "${module_name}/host.conf.erb",
) {

  include ::dhcp::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_hash($hash_data)
  validate_string($subnet)
  validate_re($subnet, '^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$')
  validate_array($global_options)
  validate_string($template)

  concat::fragment {"dhcp.host.${name}":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
    content => template($template),
    notify  => Service['dhcpd'],
  }
}
