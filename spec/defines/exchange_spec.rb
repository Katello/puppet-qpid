require 'spec_helper'

describe 'qpid::config::exchange' do
  let :title do
    'event'
  end

  context 'without ssl_cert' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_qpid__config_cmd('ensure exchange event')
        .with_command('add exchange topic event --durable')
        .with_unless('exchanges event')
        .with_hostname('localhost')
        .with_port(nil)
        .with_ssl_cert(nil)
        .with_ssl_key(nil)
    end
  end

  context 'with ssl_cert' do
    let :params do
      {
        'hostname' => 'myhost.example.com',
        'port'     => 5671,
        'ssl_cert' => '/path/to/cert.pem',
        'ssl_key'  => '/path/to/key.pem',
      }
    end

    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_qpid__config_cmd('ensure exchange event')
        .with_command('add exchange topic event --durable')
        .with_unless('exchanges event')
        .with_hostname('myhost.example.com')
        .with_port(5671)
        .with_ssl_cert('/path/to/cert.pem')
        .with_ssl_key('/path/to/key.pem')
    end
  end
end
