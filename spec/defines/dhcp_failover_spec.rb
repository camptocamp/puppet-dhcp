require 'spec_helper'

describe 'dhcp::failover' do
  let (:title) { 'failover-dhcp' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
          :domain         => 'example.com',
          :ipaddress      => '1.2.3.3',
        })
      end

      let(:pre_condition) do
          "include dhcp::server"
      end

      context 'when passing wrong value for ensure' do
        let (:params) { {
          :ensure       => 'foo',
          :peer_address => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got 'foo'/)
        end
      end

      context 'when passing wrong type for address' do
        let (:params) { {
          :address      => true,
          :peer_address => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing wrong value for address' do
        let (:params) { {
          :address      => 'foo',
          :peer_address => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got /)
        end
      end

      context 'when not passing peer_address' do
        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /peer_address/)
        end
      end

      context 'when passing wrong type for peer_address' do
        let (:params) { {
          :peer_address => true,
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing wrong value for peer_address' do
        let (:params) { {
          :peer_address => 'foo',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got /)
        end
      end

      context 'when passing wrong type for peer_port' do
        let (:params) { {
          :peer_port    => 'foo',
          :peer_address => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got String/)
        end
      end

      context 'when passing wrong type for port' do
        let (:params) { {
          :peer_address => '1.2.3.4',
          :port         => 'foo',
        } }

        it 'should fail' do
          expect {
            should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf')
          }.to raise_error(Puppet::Error, /got String/)
        end
      end



      context 'when using defaults' do
        let (:params) { {
          :peer_address => '1.2.3.4',
        } }

        it { should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf').with(
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root'
        ).with_content(
          /failover peer "failover-dhcp" \{\n/
        ).with_content(
          /primary;\n/
        ).with_content(
          /address 1.2.3.3;\n/
        ).with_content(
          /port 647;\n/
        ).with_content(
          /peer address 1.2.3.4;\n/
        ).with_content(
          /peer port 647;\n/
        ) }
        it { should contain_concat__fragment('dhcp.failover.failover-dhcp').with({
          :content => "include \"/etc/dhcp/failover.d/failover-dhcp.conf\";\n",
          :target  => '/etc/dhcp/dhcpd.conf',
        })}
      end

      context 'when passing options as a hash' do
        let (:params) { {
          :peer_address => '1.2.3.4',
          :options      => {
            'max-response-delay'       => '30',
            'max-unacked-updates'      => '10',
            'load balance max seconds' => '3',
            'mclt'                     => '1800',
            'split'                    => '128',
          },
        } }

        it { should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf').with({
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root'
        }).with_content(
          /failover peer "failover-dhcp" \{\n/
        ).with_content(
          /  load balance max seconds 3;\n/
        ).with_content(
          /  max-response-delay 30;\n/
        ).with_content(
          /  max-unacked-updates 10;\n/
        ).with_content(
          /  mclt 1800;\n/
        ).with_content(
          /  split 128;\n/
        ) }
      end

      context 'when overriding all parameters' do
        let (:params) { {
          :peer_address => '1.2.3.4',
          :address      => '1.2.3.5',
          :peer_port    => 847,
          :port         => 847,
          :options      => {
            'mclt' => 1800,
          },
          :role         => 'secondary',
        } }

        it { should contain_file('/etc/dhcp/failover.d/failover-dhcp.conf').with({
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root'
        }).with_content(
          /secondary;\n/
        ).with_content(
          /address 1.2.3.5;\n/
        ).with_content(
          /port 847;\n/
        ).with_content(
          /peer port 847;\n/
        ).with_content(
          /mclt 1800;\n/
        ) }
      end
    end
  end
end
