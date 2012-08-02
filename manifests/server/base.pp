/*

= Class dhcp::server::base
Do NOT include this class - it won't work at all.
Set variables for package name and so on.
This class should be inherited in dhcp::server::$operatingsystem.

*/
class dhcp::server::base {

  include dhcp::params
  include concat::setup
  
  package {"dhcp-server":
    ensure => present,
    name   => $dhcp::params::srv_dhcpd,
  }

  service {"dhcpd":
    name    => $dhcp::params::srv_dhcpd,
    ensure  => running,
    enable  => true,
    require => Package["dhcp-server"],
  }

  concat {"${dhcp::params::config_dir}/dhcpd.conf":
    owner => root,
    group => root,
    mode  => '0644',
  }

  concat::fragment {"00.dhcp.server.base":
    ensure  => present,
    target  => "${dhcp::params::config_dir}/dhcpd.conf",
    require => Package["dhcp-server"],
    notify  => Service["dhcpd"],
  }

  file {"${dhcp::params::config_dir}/dhcpd.conf.d":
    ensure => directory,
    mode   => 0700,
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/dhcp/empty"
  }

  file {"${dhcp::params::config_dir}/subnets":
    ensure => directory,
    require => Package["dhcp-server"],
    notify  => Service["dhcpd"],
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/dhcp/empty"
  }

  file {"${dhcp::params::config_dir}/hosts.d":
    ensure => directory,
    require => Package["dhcp-server"],
    recurse => true,
    purge   => true,
    force   => true,
    source  => "puppet:///modules/dhcp/empty"
  }

}
