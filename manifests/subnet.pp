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
  Stdlib::IP::Address::V4           $broadcast,
  Enum['present', 'absent']         $ensure = present,
  Stdlib::IP::Address::V4           $netmask = $::netmask,
  Array[Stdlib::IP::Address::V4]    $routers = [$::netmask],
  Stdlib::IP::Address::V4           $subnet_mask = $::netmask,
  Pattern[/^\S+$/]                  $domain_name = $::domain,
  Variant[Array[String], String]    $other_opts = [],
  Boolean                           $is_shared = false
) {

  Dhcp::Subnet[$title] ~> Class['dhcp::server::service']

  include ::dhcp::params

  concat {"${dhcp::params::config_dir}/hosts.d/${name}.conf":
    owner => root,
    group => root,
    mode  => '0644',
  }

  file {"${dhcp::params::config_dir}/subnets/${name}.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    content => epp(
      "${module_name}/subnet.conf.epp",
      {
        name        => $name,
        netmask     => $netmask,
        routers     => $routers,
        subnet_mask => $subnet_mask,
        broadcast   => $broadcast,
        domain_name => $domain_name,
        other_opts  => flatten([$other_opts]),
      },
    ),
    notify  => Service['dhcpd'],
  }

  unless $is_shared {
    concat::fragment {"dhcp.subnet.${name}":
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
      content => "include \"${dhcp::params::config_dir}/subnets/${name}.conf\";\n",
    }
  }

  if $ensure == 'present' {
    concat::fragment {"dhcp.subnet.${name}.hosts":
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
      content => "include \"${dhcp::params::config_dir}/hosts.d/${name}.conf\";\n",
    }

    concat::fragment {"dhcp.subnet.${name}.base":
      target  => "${dhcp::params::config_dir}/hosts.d/${name}.conf",
      content => "# File managed by puppet\n",
      order   => '00',
    }
  }
}
