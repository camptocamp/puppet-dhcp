require 'spec_helper'

describe 'dhcp::subnet' do
  let (:title) { '1.2.3.4' }
  let (:facts) { {
    :operatingsystem => 'Debian',
    :osfamily        => 'Debian',
    :lsbdistcodename => 'squeeze',
    :netmask_eth0    => '255.255.255.0',
    :domain          => 'example.com',
  } }

  context 'when passing wrong value for ensure' do
    let (:params) { {
      :ensure    => 'running',
      :broadcast => '1.2.3.4',
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /\$ensure must be either 'present' or 'absent', got 'running'/)
    end
  end

  context 'when not passing broadcast' do
    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /Must pass broadcast to Dhcp::Subnet/)
    end
  end

  context 'when passing wrong type for broadcast' do
    let (:params) { {
      :broadcast => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /true is not a string\./)
    end
  end

  context 'when passing wrong value for broadcast' do
    let (:params) { {
      :broadcast => 'foo',
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /"foo" does not match/)
    end
  end

  context 'when passing wrong type for netmask' do
    let (:params) { {
      :broadcast => '1.2.3.4',
      :netmask   => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /true is not a string\./)
    end
  end

  context 'when passing wrong value for netmask' do
    let (:params) { {
      :broadcast => '1.2.3.4',
      :netmask   => 'foo',
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /"foo" does not match/)
    end
  end

  context 'when passing wrong type for routers' do
    let (:params) { {
      :broadcast => '1.2.3.4',
      :routers   => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /true is not an Array\./)
    end
  end

  context 'when passing wrong type for subnet_mask' do
    let (:params) { {
      :broadcast   => '1.2.3.4',
      :subnet_mask => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /true is not a string\./)
    end
  end

  context 'when passing wrong type for domain_name' do
    let (:params) { {
      :broadcast   => '1.2.3.4',
      :domain_name => true,
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /true is not a string\./)
    end
  end

  context 'when passing wrong type for is_shared' do
    let (:params) { {
      :broadcast => '1.2.3.4',
      :is_shared => 'foo',
    } }

    it 'should fail' do
      expect {
        should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf')
      }.to raise_error(Puppet::Error, /"foo" is not a boolean\./)
    end
  end

  context 'when using defaults' do
    let (:params) { {
      :broadcast => '1.2.3.4',
    } }

    it { should contain_concat('/etc/dhcp/hosts.d/1.2.3.4.conf').with(
      :owner => 'root',
      :group => 'root',
      :mode  => '0644'
    ) }

    it { should contain_file('/etc/dhcp/subnets/1.2.3.4.conf').with(
        :ensure  => 'present',
        :owner   => 'root',
        :group   => 'root'
      ).with_content(
        /subnet 1\.2\.3\.4 netmask 255\.255\.255\.0 \{\n/
      ).with_content(
        /option routers 255\.255\.255\.0;\n/
      ).with_content(
        /option subnet-mask 255\.255\.255\.0;\n/
      ).with_content(
        /option broadcast-address 1\.2\.3\.4;\n/
      ).with_content(
        /option domain-name "example\.com";\n/
      ) }

    it { should contain_concat__fragment('dhcp.subnet.1.2.3.4').with(
      :ensure  => 'absent'
    ) }

    it { should contain_concat__fragment('dhcp.subnet.1.2.3.4.hosts').with(
      :ensure  => 'present',
      :target  => '/etc/dhcp/dhcpd.conf',
      :content => "include \"/etc/dhcp/hosts.d/1\.2\.3\.4\.conf\";\n"
    ) }

    it { should contain_concat__fragment('dhcp.subnet.1.2.3.4.base').with(
      :ensure  => 'present',
      :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf',
      :content => "# File managed by puppet\n",
      :order   => '00'
    ) }
  end

  context 'when is_shared is true' do
    let (:params) { {
      :broadcast => '1.2.3.4',
      :is_shared => true,
    } }

    it { should contain_concat__fragment('dhcp.subnet.1.2.3.4').with(
      :ensure  => 'present',
      :target  => '/etc/dhcp/dhcpd.conf',
      :content => "include \"/etc/dhcp/subnets/1.2.3.4.conf\";\n"
    ) }
  end

  context 'when passing other_opts as array' do
    let (:params) { {
      :broadcast   => '1.2.3.4',
      :other_opts  => ['foo', 'bar'],
    } }

    it { should contain_file('/etc/dhcp/subnets/1.2.3.4.conf').with(
        :ensure  => 'present',
        :owner   => 'root',
        :group   => 'root'
      ).with_content(
        /  foo;\n  bar;\n/
      ) }
  end

  context 'when passing other_opts as string' do
    let (:params) { {
      :broadcast   => '1.2.3.4',
      :other_opts  => 'bar',
    } }

    it { should contain_file('/etc/dhcp/subnets/1.2.3.4.conf').with(
        :ensure  => 'present',
        :owner   => 'root',
        :group   => 'root'
      ).with_content(
        /  bar;\n/
      ) }
  end

  context 'when overriding all parameters' do
    let (:params) { {
      :broadcast   => '1.2.3.4',
      :netmask     => '255.1.2.0',
      :routers     => ['2.3.4.5', '3.4.5.6'],
      :subnet_mask => '255.255.1.0',
      :domain_name => 'foo.io',
      :other_opts  => ['foo', 'bar'],
    } }

    it { should contain_file('/etc/dhcp/subnets/1.2.3.4.conf').with(
        :ensure  => 'present',
        :owner   => 'root',
        :group   => 'root'
      ).with_content(
        /subnet 1\.2\.3\.4 netmask 255\.1\.2\.0 \{\n/
      ).with_content(
        /option routers 2\.3\.4\.5,3\.4\.5\.6;\n/
      ).with_content(
        /option subnet-mask 255\.255\.1\.0;\n/
      ).with_content(
        /option broadcast-address 1\.2\.3\.4;\n/
      ).with_content(
        /option domain-name "foo\.io";\n/
      ).with_content(
        /  foo;\n  bar;\n/
      ) }
  end
end
