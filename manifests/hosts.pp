# Definition: dhcp::hosts
#
# Creates a dhcp configuration for the given hosts
#
# Parameters:
#   ['template']       -  DHCP host template - default: 'dhcp/host.conf.erb'
#   ['global_options'] -  An array of global options for the whole bunch of
#                         hosts.  You may override it per host, setting the
#                         host "options" directly in the hash.
#   ['subnet']         -  Targeted subnet
#   ['hash_data']      -  Hash containing data - default form:
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
# Sample usage:
#   ::dhcp::hosts { 'workstations':
#     subnet    => '192.168.1.0',
#      'hash_data' => {
#        'host1' => {
#          'interfaces' => {
#            'eth0'  => '00:11:22:33:44:55',
#            'wlan0' => '00:aa:bb:44:55:ff',
#          },
#        },
#        'host2' => {
#          'interfaces' => {
#            'eth1'  => '00:11:af:33:44:55',
#          },
#          'fixed_address' => 'foo.example.com',
#          'options'        => ['opt1'],
#        },
#      },
#   }
#
# Requires:
#   - puppetlabs/stdlib
#   - ripienaar/concat
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

  if $ensure == 'present' {
    concat::fragment {"dhcp.host.${name}":
      target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
      content => template($template),
      notify  => Service['dhcpd'],
    }
  }
}
