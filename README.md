# DHCP module for Puppet

[![Puppet Forge](http://img.shields.io/puppetforge/v/camptocamp/dhcp.svg)](https://forge.puppetlabs.com/camptocamp/dhcp)
[![Build Status](https://travis-ci.org/camptocamp/puppet-dhcp.png?branch=master)](https://travis-ci.org/camptocamp/puppet-dhcp)

**Manages dhcp configuration under Debian.**

This module is provided by [Camptocamp](http://www.camptocamp.com/)

## Classes

* dhcp
* dhcp::server

### dhcp

The `dhcp` class is a wrapper around `dhcp::server`:

    include ::dhcp

### dhcp::server

Installs a DHCP server:

     class { 'dhcp::server':
       opts => ['domain-name "toto.ltd"',
                'domain-name-servers 192.168.21.1'],
     }

## Definitions

* dhcp::hosts
* dhcp::shared\_network
* dhcp::subnet

### dhcp::hosts

Creates a DHCP configuration for the given hosts:

    dhcp::hosts { 'workstations':
      subnet    => '192.168.1.0',
       'hash_data' => {
         'host1' => {
           'interfaces' => {
             'eth0'  => '00:11:22:33:44:55',
             'wlan0' => '00:aa:bb:44:55:ff',
           },
         },
         'host2' => {
           'interfaces' => {
             'eth1'  => '00:11:af:33:44:55',
           },
           'fixed_address' => 'foo.example.com',
           'options'        => ['opt1'],
         },
       },
    }

### dhcp::shared\_network

Creates a shared-network entry:

    dhcp::shared_network { 'office':
      subnets => ['192.168.1.0', '192.168.2.0'],
    }

### dhcp::subnet

Creates a subnet:

    dhcp::subnet {"10.27.20.0":
      ensure     => present,
      broadcast  => "10.27.20.255",
      other_opts => ['filename "pxelinux.0";', 'next-server 10.27.10.1;'],
    }

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-dhcp/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-dhcp/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2013 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

