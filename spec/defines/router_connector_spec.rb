require 'spec_helper'

describe 'qpid::router::connector' do
  let(:title) { 'broker' }

  let(:params) do
    {
      host: '127.0.0.1',
      port: 5672,
      role: 'inter-router',
      ssl_profile: 'router-ssl',
      sasl_username: 'qpid_user',
      sasl_password: 'qpid_password',
      idle_timeout: 0,
      config_file: '/etc/qpid-dispatch/qdrouterd.conf',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it 'has connector fragment' do
    verify_concat_fragment_exact_contents(catalogue, 'qdrouter+connector_broker.conf', [
                                            'connector {',
                                            '    name: broker',
                                            '    host: 127.0.0.1',
                                            '    port: 5672',
                                            '    sasl-mechanisms: ANONYMOUS',
                                            '    sasl-username: qpid_user',
                                            '    sasl-password: qpid_password',
                                            '    role: inter-router',
                                            '    ssl-profile: router-ssl',
                                            '    idle-timeout-seconds: 0',
                                            '}'
                                          ],)
  end
end
