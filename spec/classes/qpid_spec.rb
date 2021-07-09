require 'spec_helper'

describe 'qpid' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { {} }

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('qpid::install') }
        it 'installs message store by default' do
          is_expected.to contain_package('qpid-cpp-server-linearstore')
            .that_comes_before(['Service[qpidd]'])
        end

        it { is_expected.to contain_class('qpid::config') }
        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no'
                                ],)
        end

        it { is_expected.to contain_class('qpid::service') }
        it 'configures systemd' do
          is_expected.to contain_systemd__service_limits('qpidd.service')
            .with_ensure('absent')
            .that_notifies('Service[qpidd]')
          is_expected.to contain_systemd__dropin_file('wait-for-port.conf')
            .with_ensure('absent')
            .that_notifies('Service[qpidd]')
        end
      end

      context 'with ensure absent' do
        let(:params) do
          super().merge(
            ensure: 'absent',
            auth: true,
            ssl: true,
            ssl_port: 5671,
            ssl_cert_db: '/etc/pki/katello/nssdb',
            ssl_cert_password_file: '/etc/pki/katello/nssdb/nss_db_password-file',
            ssl_cert_name: 'broker',
            ssl_require_client_auth: true,

          )
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('qpid::install') }
        it { is_expected.to contain_package('qpid-cpp-server').with_ensure('purged') }
        it { is_expected.to contain_package('qpid-cpp-client').with_ensure('purged') }
        it { is_expected.to contain_package('qpid-cpp-server-linearstore').with_ensure('purged') }
        it { is_expected.not_to contain_package('cyrus-sasl-plain') }
        it { is_expected.to contain_package('qpid-tools').with_ensure('purged') }

        it { is_expected.to contain_class('qpid::config') }
        it { is_expected.to contain_group('qpidd').with_ensure('absent') }
        it { is_expected.to contain_user('qpidd').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/qpid/qpidd.conf').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/qpid/qpid.acl').with_ensure('absent') }
        it { is_expected.to contain_file('/var/lib/qpidd').with_ensure('absent') }

        it { is_expected.to contain_class('qpid::service') }
        it { is_expected.to contain_systemd__dropin_file('wait-for-port.conf').with_ensure('absent') }
        it { is_expected.to contain_systemd__service_limits('qpidd.service').with_ensure('absent') }
        it { is_expected.not_to contain_package('iproute') }
        it 'disables qpidd' do
          is_expected.to contain_service('qpidd')
            .with_ensure('false')
            .with_enable('false')
        end
      end

      context 'with services stopped' do
        let(:params) { super().merge(service_ensure: false) }

        it { is_expected.to compile.with_all_deps }

        it 'disables qpidd' do
          is_expected.to contain_service('qpidd')
            .with_ensure('false')
            .with_enable('false')
        end
      end

      context 'with service limits' do
        let(:params) { super().merge(open_file_limit: 100) }

        it { is_expected.to compile.with_all_deps }

        it 'configures systemd' do
          is_expected.to contain_systemd__service_limits('qpidd.service')
            .with_ensure('present')
            .with_limits('LimitNOFILE' => 100)
            .that_notifies('Service[qpidd]')
        end
      end

      context 'message store disabled' do
        let(:params) { super().merge(server_store: false) }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_package('qpid-cpp-server-linearstore') }
      end

      context 'with interface' do
        let(:params) { super().merge(interface: 'lo') }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'interface=lo'
                                ],)
        end
      end

      context 'with ACL file' do
        let :params do
          super().merge(
            acl_file: '/etc/qpid/qpid.acl',
            acl_content: 'allow all all',
          )
        end

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'acl-file=/etc/qpid/qpid.acl',
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                ],)
        end

        it 'creates ACL file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpid.acl', [
                                  'allow all all',
                                ],)
        end
      end

      context 'with ssl options' do
        let :params do
          super().merge(
            ssl: true,
            ssl_port: 5671,
            ssl_cert_db: '/etc/pki/katello/nssdb',
            ssl_cert_password_file: '/etc/pki/katello/nssdb/nss_db_password-file',
            ssl_cert_name: 'broker',
            ssl_require_client_auth: true,
          )
        end

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'require-encryption=yes',
                                  'ssl-require-client-authentication=yes',
                                  'ssl-port=5671',
                                  'ssl-cert-db=/etc/pki/katello/nssdb',
                                  'ssl-cert-password-file=/etc/pki/katello/nssdb/nss_db_password-file',
                                  'ssl-cert-name=broker'
                                ],)
        end

        it 'configures systemd to wait for the ssl port to be open' do
          is_expected.to contain_systemd__dropin_file('wait-for-port.conf')
            .with_ensure('present')
            .that_notifies('Service[qpidd]')
            .that_requires('Package[iproute]')
          is_expected.to contain_package('iproute')
            .with_ensure('present')
          verify_exact_contents(catalogue, '/etc/systemd/system/qpidd.service.d/wait-for-port.conf', [
                                  '[Service]',
                                  "ExecStartPost=/bin/bash -c 'while ! ss --no-header --tcp --listening --numeric sport = :5671 | grep -q \"^LISTEN.*:5671\"; do sleep 1; done'"
                                ],)
        end
      end

      context 'with session-max-unacked' do
        let(:params) { super().merge(session_unacked: 10) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'session-max-unacked=10'
                                ],)
        end
      end

      context 'with mgmt-pub-interval' do
        let(:params) { super().merge(mgmt_pub_interval: 4) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'mgmt-pub-interval=4'
                                ],)
        end
      end

      context 'with wcache_page_size' do
        let(:params) { super().merge(wcache_page_size: 4) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'wcache-page-size=4'
                                ],)
        end
      end

      context 'with default_queue_limit' do
        let(:params) { super().merge(default_queue_limit: 10_000) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'default-queue-limit=10000'
                                ],)
        end
      end

      context 'with custom_settings' do
        let :pre_condition do
          <<-PUPPET
          class {'qpid':
            custom_settings => {
              efp-file-size => 512,
              log-to-file   => '/tmp/qpidd.log',
            },
          }
          PUPPET
        end

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'efp-file-size=512',
                                  'log-to-file=/tmp/qpidd.log',
                                ],)
        end
      end

      context 'with max-connections' do
        let(:params) { super().merge(max_connections: 2000) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=no',
                                  'max-connections=2000'
                                ],)
        end
      end

      context 'with auth' do
        let(:params) { super().merge(auth: true) }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidd.conf', [
                                  'data-dir=/var/lib/qpidd',
                                  'log-enable=error+',
                                  'log-to-syslog=yes',
                                  'auth=yes',
                                ],)
        end
        it 'installs cyrus-sasl-plain' do
          is_expected.to contain_package('cyrus-sasl-plain')
        end
      end
    end
  end
end
