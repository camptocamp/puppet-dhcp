require 'spec_helper_acceptance'

describe 'dhcp::failover with dhcp::shared_network' do
  describe 'with defaults' do
    it 'should work with no error' do
      pp = <<-EOS
      class { 'dhcp::server': }

      dhcp::shared_network {'office':
        subnets => ['${sub}.10.0', '${sub}.11.0', '${sub}.12.0'],
      }


      dhcp::failover {'my-failover':
        peer_address => '1.1.1.1',
        options      => {
          'max-response-delay'       => 30,
          'max-unacked-updates'      => 10,
          'load balance max seconds' => 3,
          'mclt'                     => 1800,
          'split'                    => 128,
        }
      }
      $ipaddr = split($::networking['interfaces']['eth0']['ip'], '[.]')
      $sub = "${ipaddr[0]}.${ipaddr[1]}"
      dhcp::subnet {${sub}.10.0:
        broadcast   => "${sub}.10.255",
        subnet_mask => '255.255.0.0',
        domain_name => 'example.com',
        other_opts  => [
          "option domain-name-servers ${sub}.10.1, ${sub}.10.2",
          'option domain-search "example.com", "internal.example.com"',
          'pool {',
          '}',
        ]
      }
      dhcp::subnet {${sub}.11.0:
        broadcast   => "${sub}.11.255",
        subnet_mask => '255.255.0.0',
        domain_name => 'example.com',
        other_opts  => [
          "option domain-name-servers ${sub}.11.1, ${sub}.11.2",
          'option domain-search "example.com", "internal.example.com"',
          'pool {',
          '}',
        ]
      }
      dhcp::subnet {${sub}.12.0:
        broadcast   => "${sub}.12.255",
        subnet_mask => '255.255.0.0',
        domain_name => 'example.com',
        other_opts  => [
          "option domain-name-servers ${sub}.12.1, ${sub}.12.2",
          'option domain-search "example.com", "internal.example.com"',
          'pool {',
          'failover peer "my-failover"',
          "range ${sub}.12.100 ${sub}.12.250",
          '}',
        ]
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  end
end
