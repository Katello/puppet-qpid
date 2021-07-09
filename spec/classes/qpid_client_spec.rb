require 'spec_helper'

describe 'qpid::client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_package('qpid-cpp-client-devel') }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidc.conf', [
                                  'log-enable=error+',
                                ],)
        end
      end

      context 'with ssl options' do
        let :params do
          {
            ssl: true,
            ssl_port: 5671,
            ssl_cert_db: '/etc/pki/katello/nssdb',
            ssl_cert_password_file: '/etc/pki/katello/nssdb/nss_db_password-file',
            ssl_cert_name: 'broker',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_package('qpid-cpp-client-devel') }

        it 'creates configuration file' do
          verify_exact_contents(catalogue, '/etc/qpid/qpidc.conf', [
                                  'log-enable=error+',
                                  'ssl-port=5671',
                                  'ssl-cert-db=/etc/pki/katello/nssdb',
                                  'ssl-cert-password-file=/etc/pki/katello/nssdb/nss_db_password-file',
                                  'ssl-cert-name=broker'
                                ],)
        end
      end
    end
  end
end
