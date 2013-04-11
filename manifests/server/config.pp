class dhcp::server::config {
  include ::dhcp::params
  include ::concat::setup

  concat {"${dhcp::params::config_dir}/dhcpd.conf":
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment {'00.dhcp.server.base':
    ensure  => present,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => template($dhcp::params::base_template),
  }

  file {"${dhcp::params::config_dir}/dhcpd.conf.d":
    ensure  => directory,
    mode    => '0700',
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/${module_name}/empty"
  }

  file {"${dhcp::params::config_dir}/subnets":
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/${module_name}/empty",
    require => Package['dhcp-server'],
    notify  => Service['dhcpd'],
  }

  file {"${dhcp::params::config_dir}/hosts.d":
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/${module_name}/empty",
  }
}
