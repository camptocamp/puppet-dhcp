require 'spec_helper'

describe 'dhcp::hosts' do
  let (:title) { 'My hosts' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/var/lib/puppet/concat',
        })
      end

      let(:pre_condition) do
        "include ::dhcp::server"
      end

      context 'when passing wrong value for ensure' do
        let (:params) { {
          :hash_data => {},
          :subnet    => '1.2.3.4',
          :ensure    => 'running'
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got 'running'/)
        end
      end

      context 'when hash_data is not passed' do
        let (:params) { {
          :subnet    => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /hash_data/)
        end
      end

      context 'when passing wrong type for hash_data' do
        let (:params) { {
          :hash_data => 'foo',
          :subnet    => '1.2.3.4',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got String/)
        end
      end

      context 'when subnet is not passed' do
        let (:params) { {
          :hash_data => {},
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /subnet/)
        end
      end

      context 'when passing wrong type for subnet' do
        let (:params) { {
          :hash_data => {},
          :subnet    => true
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing wrong value for subnet' do
        let (:params) { {
          :hash_data => {},
          :subnet    => 'foo'
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got /)
        end
      end

      context 'when passing wrong type for template' do
        let (:params) { {
          :hash_data => {},
          :subnet    => '1.2.3.4',
          :template  => true
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got Boolean/)
        end
      end

      context 'when passing one entry in hash_data' do
        context 'when passing wrong type for an host data' do
          let (:params) { {
            :hash_data => {
              'host1' => true,
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got Boolean/)
          end
        end

        context 'when interfaces is not passed' do
          let (:params) { {
            :hash_data => {
              'host1' => {
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /expects size to be between 1 and 3/)
          end
        end

        context 'when passing wrong value for an interface' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth 0'  => '00:11:22:33:44:55',
                },
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got 'eth 0'/)
          end
        end

        context 'when passing wrong type for a mac address' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => true,
                },
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got Boolean/)
          end
        end

        context 'when passing wrong value for a mac address' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => 'my mac',
                },
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got 'my mac'/)
          end
        end

        context 'when passing wrong type for fixed_address' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
                'fixed_address' => true,
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got Boolean/)
          end
        end

        context 'when passing wrong value for fixed_address' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
                'fixed_address' => 'my wrong value',
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got 'my wrong value'/)
          end
        end

        context 'when not passing fixed_address' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it { should contain_concat__fragment('dhcp.host.My hosts').with(
            :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf',
            :content => /fixed-address host1;/
          ) }
        end

        context 'when not passing options' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
              },
            },
            :subnet         => '1.2.3.4',
            :global_options => ['foo', 'bar'],
          } }

          it { should contain_concat__fragment('dhcp.host.My hosts').with(
            :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf',
            :content => /foo;\nbar;\n/
          ) }
        end

        context 'when overriding options' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
                'options' => ['baz'],
              },
            },
            :subnet         => '1.2.3.4',
            :global_options => ['foo', 'bar'],
          } }

          it { should contain_concat__fragment('dhcp.host.My hosts').with(
            :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf',
            :content => /baz;\n/
          ) }
        end

        context 'when passing wrong type for options' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
                'options' => true,
              },
            },
            :subnet         => '1.2.3.4',
            :global_options => ['foo', 'bar'],
          } }

          it 'should fail' do
            expect {
              should contain_concat__fragment('dhcp.host.My hosts')
            }.to raise_error(Puppet::Error, /got Boolean/)
          end
        end

        context 'when not passing options' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                },
              },
            },
            :subnet         => '1.2.3.4',
            :global_options => ['foo', 'bar'],
          } }

          it { should contain_concat__fragment('dhcp.host.My hosts').with(
            :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf',
            :content => /foo;\nbar;\n/
          ) }
        end

        context 'when passing two hosts' do
          let (:params) { {
            :hash_data => {
              'host1' => {
                'interfaces' => {
                  'eth0'  => '00:11:22:33:44:55',
                  'wlan0' => '00:aa:bb:44:55:ff',
                },
              },
              'host2' => {
                'interfaces' => {
                  'eth1'  => '00:11:AF:33:44:55',
                },
                'fixed_address' => 'foo.example.com',
                'options'        => ['opt1'],
              },
            },
            :subnet    => '1.2.3.4'
          } }

          it { should contain_concat__fragment('dhcp.host.My hosts').with(
            :target  => '/etc/dhcp/hosts.d/1.2.3.4.conf').with_content(
              /host host1-eth0 \{\n  hardware ethernet 00:11:22:33:44:55;\n  fixed-address host1;\n\}/).with_content(
                /host host1-wlan0 \{\n  hardware ethernet 00:aa:bb:44:55:ff;\n  fixed-address host1;\n\}/).with_content(
                  /host host2-eth1 \{\n  hardware ethernet 00:11:AF:33:44:55;\n  fixed-address foo\.example\.com;\n  opt1;\n\}/)
          }
        end
      end

      context 'when overriding template' do
        let (:params) { {
          :hash_data => {},
          :subnet    => '1.2.3.4',
          :template  => 'wrong/path',
        } }

        it 'should fail' do
          expect {
            should contain_concat__fragment('dhcp.host.My hosts')
          }.to raise_error(Puppet::Error, /got 'wrong\/path'/)
        end
      end
    end
  end
end
