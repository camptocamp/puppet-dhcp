# Class: dhcp::server::config
#
# Configure the DHCP server
#
class dhcp::server::config {
  include ::dhcp::params

  validate_string($dhcp::params::config_dir)
  validate_absolute_path($dhcp::params::config_dir)
  validate_string($dhcp::params::server_template)
  validate_re($dhcp::params::server_template, '^\S+$')

  validate_string($dhcp::server::ddns_update)
  validate_bool($dhcp::server::authoritative)
  validate_array($dhcp::server::opts)

  $ddns_update = $dhcp::server::ddns_update
  $authoritative = $dhcp::server::authoritative
  $opts = $dhcp::server::opts

  concat {"${dhcp::params::config_dir}/dhcpd.conf":
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment {'00.dhcp.server.base':
    ensure  => present,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    content => template($dhcp::params::server_template),
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
  }

  file {"${dhcp::params::config_dir}/hosts.d":
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/${module_name}/empty",
  }
}
