require 'spec_helper'

describe 'dhcp::shared_network' do
  let (:title) { 'My network' }
  let (:facts) { {
    :operatingsystem => 'Debian',
    :osfamily        => 'Debian',
    :lsbdistcodename => 'squeeze',
    :id              => 'root',
    :path            => '/foo/bar'
  } }

  context 'when passing wrong value for ensure' do
    let (:params) { {
      :ensure => 'running',
    } }

    it 'should fail' do
      expect {
        should contain_concat__fragment('dhcp-shared-My network')
      }.to raise_error(Puppet::Error, /\$ensure must be either 'present' or 'absent', got 'running'/)
    end
  end

  context 'when passing wrong type for subnets' do
    let (:params) { {
      :subnets => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat__fragment('dhcp-shared-My network')
      }.to raise_error(Puppet::Error, /true is not an Array\./)
    end
  end

  context 'when passing no parameters' do
    it { should contain_concat__fragment('dhcp-shared-My network').with(
        :ensure  => 'present',
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
      }.to raise_error(Puppet::Error, /true is not a string\./)
    end
  end

  context 'when passing wrong value for a subnet' do
    let (:params) { {
      :subnets => ['wrong value'],
    } }

    it 'should fail' do
      expect {
        should contain_concat__fragment('dhcp-shared-My network')
      }.to raise_error(Puppet::Error, /"wrong value" does not match/)
    end
  end

  context 'when passing subnets' do
    let (:params) { {
      :subnets => ['1.2.3.4', '5.6.7.8'],
    } }

    it { should contain_concat__fragment('dhcp-shared-My network').with(
        :ensure => 'present',
        :target => '/etc/dhcp/dhcpd.conf'
      ).with_content(
        /shared-network My network \{\n  include "\/etc\/dhcp\/subnets\/1\.2\.3\.4\.conf";\n  include "\/etc\/dhcp\/subnets\/5\.6\.7\.8\.conf";\n\}/)
    }
  end
end
