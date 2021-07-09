require 'spec_helper'

describe 'qpid::router::listener' do
  let(:title) { 'hub' }

  let(:params) do
    {
      role: 'inter-router',
      ssl_profile: 'router-ssl',
      idle_timeout: 0,
      config_file: '/etc/qpid-dispatch/qdrouterd.conf',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it 'has listener fragment' do
    verify_concat_fragment_exact_contents(catalogue, 'qdrouter+listener_hub.conf', [
                                            'listener {',
                                            '    port: 5672',
                                            '    sasl-mechanisms: ANONYMOUS',
                                            '    role: inter-router',
                                            '    ssl-profile: router-ssl',
                                            '    idle-timeout-seconds: 0',
                                            '}'
                                          ],)
  end
end
