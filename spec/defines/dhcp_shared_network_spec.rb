require 'spec_helper'

describe 'dhcp::shared_network' do
  let (:title) { 'My network' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
        })
      end

      context 'when passing wrong value for ensure' do
        let (:params) { {
          :ensure => 'running',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp-shared-My network')
          }.to raise_error(Puppet::Error, /got 'running'/)
        end
      end

      context 'when passing wrong type for subnets' do
        let (:params) { {
          :subnets => true,
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp-shared-My network')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing no parameters' do
        it { should contain_concat__fragment('dhcp-shared-My network').with(
          :target  => '/etc/dhcp/dhcpd.conf'
        ).with_content(
          /shared-network My network \{\n\}/
        )
        }
      end

      context 'when passing wrong type for a subnet' do
        let (:params) { {
          :subnets => [true],
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp-shared-My network')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing wrong value for a subnet' do
        let (:params) { {
          :subnets => ['wrong value'],
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp-shared-My network')
          }.to raise_error(Puppet::Error, /got /)
        end
      end

      context 'when passing subnets' do
        let (:params) { {
          :subnets => ['1.2.3.4', '5.6.7.8'],
        } }

        let (:pre_condition) do
            "
            include ::dhcp::server
            ::dhcp::subnet { ['1.2.3.4', '5.6.7.8']:
              broadcast => '10.0.0.1',
            }
            "
        end

        it { should contain_concat__fragment('dhcp-shared-My network').with(
          :target => '/etc/dhcp/dhcpd.conf'
        ).with_content(
          /shared-network My network \{\n  include "\/etc\/dhcp\/subnets\/1\.2\.3\.4\.conf";\n  include "\/etc\/dhcp\/subnets\/5\.6\.7\.8\.conf";\n\}/)
        }
      end
    end
  end
end
