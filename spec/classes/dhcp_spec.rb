require 'spec_helper'

describe 'dhcp' do
  context 'When on an unsupported OS' do
    let (:facts) { {
      :operatingsystem => 'RedHat',
      :osfamily        => 'Redhat',
      :lsbdistcodename => 'Santiago'
    } }

    it 'should fail' do
      expect {
        should contain_package('dhcp-server')
      }.to raise_error(Puppet::Error, /Unsupported OS RedHat\/Santiago/)
    end
  end

  context 'When on Debian lenny' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'lenny'
    } }

    # Package
    it { should contain_package('dhcp-server').with(
      :name => 'dhcp3-server'
    ) }

    # Config
    it { should contain_concat('/etc/dhcp3/dhcpd.conf').with(
      :owner => 'root',
      :group => 'root',
      :mode  => '0644'
    ) }

    # Service
    it { should contain_service('dhcpd').with(
      :ensure  => 'running',
      :name    => 'dhcp3-server',
      :enable  => true,
      :pattern => '/usr/sbin/dhcpd3'
    ) }
  end

  context 'When on Debian squeeze' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze'
    } }

    # Package
    it { should contain_package('dhcp-server').with(
      :name => 'isc-dhcp-server'
    ) }

    # Config
    it { should contain_concat('/etc/dhcp/dhcpd.conf').with(
      :owner => 'root',
      :group => 'root',
      :mode  => '0644'
    ) }

    # Service
    it { should contain_service('dhcpd').with(
      :ensure  => 'running',
      :name    => 'isc-dhcp-server',
      :enable  => true,
      :pattern => '/usr/sbin/dhcpd'
    ) }
  end
end
