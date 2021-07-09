require 'spec_helper'

describe 'qpid::router::link_route' do
  let(:title) { 'broker-link' }

  let(:params) do
    {
      connection: 'broker',
      direction: 'in',
      prefix: 'unicorn.',
      config_file: '/etc/qpid-dispatch/qdrouterd.conf',
    }
  end

  it { is_expected.to compile.with_all_deps }
  it 'has link_route fragment' do
    verify_concat_fragment_exact_contents(catalogue, 'qdrouter+link_route_broker-link.conf', [
                                            'linkRoute {',
                                            '    prefix: unicorn.',
                                            '    direction: in',
                                            '    connection: broker',
                                            '}'
                                          ],)
  end
end
