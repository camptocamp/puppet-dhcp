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
  Dhcp::Hosts_data                  $hash_data,
  Stdlib::IP::Address::V4           $subnet,
  Enum['present', 'absent']         $ensure = present,
  Variant[Array[String], String]    $global_options = [],
  Pattern['\.epp$']                 $template = "${module_name}/host.conf.epp",
) {

  include ::dhcp::params

  if $ensure == 'present' {
    concat::fragment {"dhcp.host.${name}":
      target  => "${dhcp::params::config_dir}/hosts.d/${subnet}.conf",
      content => epp(
        $template,
        {
          hash_data      => $hash_data,
          global_options => flatten([$global_options]),
        },
      ),
      notify  => Service['dhcpd'],
    }
  }
}
