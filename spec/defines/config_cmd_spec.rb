require 'spec_helper'

describe 'qpid::config_cmd' do
  let(:title) { 'test' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      [true, false].each do |qpid|
        context "qpid => #{qpid}" do
          context 'with unless' do
            let :params do
              {
                'command' => 'add exchange topic myexchange --durable',
                'unless'  => 'exchanges myexchange',
              }
            end

            if qpid
              let :pre_condition do
                'include qpid'
              end

            end

            it do
              is_expected.to contain_exec('qpid-config test')
                .with_command('qpid-config -b amqp://localhost:5672 add exchange topic myexchange --durable')
                .with_onlyif(nil)
                .with_unless('qpid-config -b amqp://localhost:5672 exchanges myexchange')
                .with_path('/usr/bin')
                .with_logoutput(true)

              if qpid
                is_expected.to contain_service('qpidd')
                is_expected.to contain_exec('qpid-config test').that_requires('Service[qpidd]')
              else
                is_expected.not_to contain_service('qpidd')
                is_expected.not_to contain_exec('qpid-config test').that_requires('Service[qpidd]')
              end
            end

            context 'with sasl_mechanism and username' do
              let(:params) { super().merge(sasl_mechanism: 'EXTERNAL', username: 'myuser') }

              it do
                is_expected.to contain_exec('qpid-config test')
                  .with_command('qpid-config --sasl-mechanism=EXTERNAL -b amqp://myuser@localhost:5672 add exchange topic myexchange --durable')
                  .with_unless('qpid-config --sasl-mechanism=EXTERNAL -b amqp://myuser@localhost:5672 exchanges myexchange')
              end
            end
          end

          context 'with onlyif' do
            let :params do
              {
                'command' => 'bind myexchange myqueue *.*',
                'onlyif'  => 'exchanges myexchange -r | grep *.*',
              }
            end

            if qpid
              let :pre_condition do
                'include qpid'
              end

            end

            it do
              is_expected.to contain_exec('qpid-config test')
                .with_command('qpid-config -b amqp://localhost:5672 bind myexchange myqueue *.*')
                .with_onlyif('qpid-config -b amqp://localhost:5672 exchanges myexchange -r | grep *.*')
                .with_unless(nil)
                .with_path('/usr/bin')
                .with_logoutput(true)

              if qpid
                is_expected.to contain_service('qpidd')
                is_expected.to contain_exec('qpid-config test').that_requires('Service[qpidd]')
              else
                is_expected.not_to contain_service('qpidd')
                is_expected.not_to contain_exec('qpid-config test').that_requires('Service[qpidd]')
              end
            end
          end
        end
      end

      context 'with neither onlyif nor unless' do
        let :params do
          {
            'command' => 'cmd',
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Either \$onlyif or \$unless must be specified}) }
      end

      context 'with SSL' do
        let :params do
          {
            'command'  => 'cmd',
            'onlyif'   => 'condition',
            'ssl_cert' => 'cert.pem',
            'ssl_key'  => 'key.pem',
          }
        end

        it do
          is_expected.to contain_exec('qpid-config test')
            .with_command('qpid-config --ssl-certificate cert.pem --ssl-key key.pem -b amqps://localhost:5671 cmd')
            .with_onlyif('qpid-config --ssl-certificate cert.pem --ssl-key key.pem -b amqps://localhost:5671 condition')
        end

        context 'with sasl_mechanism and username' do
          let(:params) { super().merge(sasl_mechanism: 'EXTERNAL', username: 'myuser') }

          it do
            is_expected.to contain_exec('qpid-config test')
              .with_command('qpid-config --sasl-mechanism=EXTERNAL --ssl-certificate cert.pem --ssl-key key.pem -b amqps://myuser@localhost:5671 cmd')
              .with_onlyif('qpid-config --sasl-mechanism=EXTERNAL --ssl-certificate cert.pem --ssl-key key.pem -b amqps://myuser@localhost:5671 condition')
          end
        end
      end

      context 'with only $ssl_cert' do
        let :params do
          {
            'command'  => 'cmd',
            'onlyif'   => 'condition',
            'ssl_cert' => 'cert.pem',
          }
        end

        it { is_expected.to compile.and_raise_error(%r{When using SSL both, \$ssl_cert and \$ssl_key must be specified}) }
      end

      context 'with only $ssl_key' do
        let :params do
          {
            'command' => 'cmd',
            'onlyif'  => 'condition',
            'ssl_key' => 'key.pem',
          }
        end

        it { is_expected.to compile.and_raise_error(%r{When using SSL both, \$ssl_cert and \$ssl_key must be specified}) }
      end
    end
  end
end
