define dhcp::failover(
  Stdlib::IP::Address::V4      $peer_address,
  Enum['present', 'absent']    $ensure    = present,
  Stdlib::IP::Address::V4      $address   = $::ipaddress,
  Integer                      $peer_port = 647,
  Integer                      $port      = 647,
  Hash                         $options   = {},
  Enum['primary', 'secondary'] $role      = 'primary',
) {

  include ::dhcp::params

  $my_ensure = $ensure? {
    'present' => 'file',
    default   => $ensure,
  }

  file {"${dhcp::params::config_dir}/failover.d/${name}.conf":
    ensure  => $my_ensure,
    content => epp(
      "${module_name}/failover.conf.epp",
      {
        name         => $name,
        role         => $role,
        address      => $address,
        peer_address => $peer_address,
        port         => $port,
        peer_port    => $peer_port,
        options      => $options,
      },
    ),
    group   => 'root',
    mode    => '0644',
    notify  => Service['dhcpd'],
    owner   => 'root',
  }

  if $ensure == 'present' {
    concat::fragment {"dhcp.failover.${name}":
      content => "include \"${dhcp::params::config_dir}/failover.d/${name}.conf\";\n",
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
    }
  }

}
