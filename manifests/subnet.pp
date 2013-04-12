# = Definition: dhcp::subnet
# Creates a subnet
#
# Arguments:
#  *$broadcast*   : subnet broadcast (mandatory)
#  *$netmask*     : subnet netmask (if not set, takes eth0 netmask)
#  *$routers*     : subnet routers (array)  (if not set, takes eth0 IP)
#  *$subnet_mask* : netmask sent to dhcp guests (if not set, takes
#                   $netmask, or netmask_eth0)
#  *$domain_name* : subnet domain name (if not set, takes server domain)
#  *$other_opts*  : any other DHCPD option, as an array
#  *$is_shared*   : whether it's part of a shared network or not. Default: false
#
# Example:
#
# node "dhcp.domain.ltd" {
#   $dhcpd_domain_name = 'domain.ltd'
#   $dhcpd_dns_servers = '10.27.21.1, 10.26.21.1'
#   include dhcp
#
#   dhcp::subnet {"10.27.20.0":
#     ensure     => present,
#     broadcast  => "10.27.20.255",
#     other_opts => ['filename "pxelinux.0";', 'next-server 10.27.10.1;'],
#   }
# }
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
    true  => $ensure,
    false => 'absent',
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
