require 'spec_helper_acceptance'

describe 'dhcp::failover' do
  describe 'with defaults' do
    it 'should work with no error' do
      pp = <<-EOS
      class { 'dhcp::server': }
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
      $sub = "${ipaddr[0]}.${ipaddr[1]}.${ipaddr[2]}"
      dhcp::subnet {$::networking['interfaces']['eth0']['network']:
        broadcast   => "${sub}.255",
        subnet_mask => $::networking['interfaces']['eth0']['netmask'],
        domain_name => 'test.com',
        other_opts  => [
          "option domain-name-servers ${sub}.1, ${sub}.2",
          'option domain-search "test.com", "internal.test.com"',
          'pool {',
          'failover peer "my-failover"',
          "range ${sub}.100 ${sub}.250",
          '}',
        ]
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  end
end
