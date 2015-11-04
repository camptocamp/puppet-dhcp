# Definition: dhcp::subnet
#
# Creates a subnet
#
# Parameters:
#  ['broadcast']   : subnet broadcast (mandatory)
#  ['netmask']     : subnet netmask
#                    (default: $::netmask_eth0)
#  ['routers']     : An array of subnet routers
#                    (default: $::netmask)
#  ['subnet_mask'] : netmask sent to dhcp guests
#                    (default: the value of $netmask)
#  ['domain_name'] : subnet domain name
#                    (default: $::domain)
#  ['other_opts']  : An array of additional DHCPD options
#  ['is_shared']   : whether it's part of a shared network or not
#                    (default: false)
#
# Sample usage:
#   dhcp::subnet {"10.27.20.0":
#     ensure     => present,
#     broadcast  => "10.27.20.255",
#     other_opts => ['filename "pxelinux.0";', 'next-server 10.27.10.1;'],
#   }
#
define dhcp::subnet(
  $broadcast,
  $ensure = present,
  $netmask = undef,
  $routers = [],
  $subnet_mask = undef,
  $domain_name = undef,
  $other_opts = [],
  $is_shared = false
) {

  Dhcp::Subnet[$title] ~> Class['dhcp::server::service']

  include ::dhcp::params

  $ip_re = '^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$'

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_string($broadcast)
  validate_re($broadcast, $ip_re)
  validate_string($netmask)
  validate_array($routers)
  validate_string($subnet_mask)
  validate_string($domain_name)
  validate_bool($is_shared)

  concat {"${dhcp::params::config_dir}/hosts.d/${name}.conf":
    owner => root,
    group => root,
    mode  => '0644',
  }

  file {"${dhcp::params::config_dir}/subnets/${name}.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    content => template("${module_name}/subnet.conf.erb"),
    notify  => Service['dhcpd'],
  }

  $ensure_shared = $is_shared ? {
    true  => 'absent',
    false => $ensure,
  }
  concat::fragment {"dhcp.subnet.${name}":
    ensure  => $ensure_shared,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => "include \"${dhcp::params::config_dir}/subnets/${name}.conf\";\n",
  }

  concat::fragment {"dhcp.subnet.${name}.hosts":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => "include \"${dhcp::params::config_dir}/hosts.d/${name}.conf\";\n",
  }

  concat::fragment {"dhcp.subnet.${name}.base":
    ensure  => $ensure,
    target  => "${dhcp::params::config_dir}/hosts.d/${name}.conf",
    content => "# File managed by puppet\n",
    order   => '00',
  }
}
