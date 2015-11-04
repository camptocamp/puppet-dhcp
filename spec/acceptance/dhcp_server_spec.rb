require 'spec_helper_acceptance'

describe 'dhcp::server' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'dhcp::server': }
        dhcp::subnet { '172.17.0.0':
          ensure     => present,
          broadcast  => '172.17.0.255',
          other_opts => ['range 172.17.0.100 172.17.0.250'],
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
