require 'spec_helper'

describe 'dhcp' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
        })
      end

      case facts[:osfamily]
      when 'Debian'
        case facts[:operatingsystemmajrelease]
        when '5'
          let(:pkg_name) { 'dhcp3-server' }
          let(:confdir) { '/etc/dhcp3' }
          let(:srv_name) { 'dhcp3-server' }
          let(:srv_pattern) { '/usr/sbin/dhcp3' }
        else
          let(:pkg_name) { 'isc-dhcp-server' }
          let(:confdir) { '/etc/dhcp' }
          let(:srv_name) { 'isc-dhcp-server' }
          let(:srv_pattern) { '/usr/sbin/dhcpd' }
        end
      end

      # Package
      it { should contain_package('dhcp-server').with(
        :name => pkg_name
      ) }

      # Config
      it { should contain_concat("#{confdir}/dhcpd.conf").with(
        :owner => 'root',
        :group => 'root',
        :mode  => '0644'
      ) }

      it { should contain_concat__fragment('00.dhcp.server.base').with(
        :ensure  => 'present',
        :target  => "#{confdir}/dhcpd.conf",
        :content => /log-facility/
      ).with_content(/ddns-update-style none;/).with_content(/#authoritative/)
      }

      # Service
      it { should contain_service('dhcpd').with(
        :ensure  => 'running',
        :name    => srv_name,
        :enable  => true,
        :pattern => srv_pattern
      ) }

      context 'when passing ddns_update' do
        context 'when passing wrong type' do
          let (:params) { {
            :server_ddns_update => true
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('00.dhcp.server.base')
            }.to raise_error(Puppet::Error, /true is not a string./)
          end
        end

        context 'when passing valid value' do
          let (:params) { {
            :server_ddns_update => 'foo'
          } }

          it { should contain_concat__fragment('00.dhcp.server.base').with(
            :ensure  => 'present',
            :target  => '/etc/dhcp/dhcpd.conf',
            :content => /log-facility/
          ).with_content(/ddns-update-style foo;/).with_content(/#authoritative/)
          }
        end
      end

      context 'when passing authoritative' do
        context 'when passing wrong type' do
          let (:params) { {
            :server_authoritative => 'foo'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('00.dhcp.server.base')
            }.to raise_error(Puppet::Error, /"foo" is not a boolean./)
          end
        end

        context 'when passing valid value' do
          let (:params) { {
            :server_authoritative => true
          } }

          it { should contain_concat__fragment('00.dhcp.server.base').with(
            :ensure  => 'present',
            :target  => '/etc/dhcp/dhcpd.conf',
            :content => /log-facility/
          ).with_content(/ddns-update-style none;/).with_content(/[^#]authoritative/)
          }
        end
      end

      context 'when passing opts' do
        context 'when passing wrong type' do
          let (:params) { {
            :server_opts => 'foo'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('00.dhcp.server.base')
            }.to raise_error(Puppet::Error, /"foo" is not an Array./)
          end
        end

        context 'when passing valid value' do
          let (:params) { {
            :server_opts => ['foo', 'bar', 'baz']
          } }

          it { should contain_concat__fragment('00.dhcp.server.base').with(
            :ensure  => 'present',
            :target  => '/etc/dhcp/dhcpd.conf',
            :content => /log-facility/
          ).with_content(/ddns-update-style none;/).with_content(/#authoritative/).with_content(/foo;\nbar;\nbaz;\n/)
          }
        end
      end
    end
  end
end
