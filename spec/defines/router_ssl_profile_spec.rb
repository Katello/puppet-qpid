require 'spec_helper'

describe 'qpid::router::ssl_profile' do
  let(:title) { 'example' }

  let(:params) do
    {
      config_file: '/etc/qpid-dispatch/qdrouterd.conf',
    }
  end

  context 'with minimal parameters' do
    let :params do
      super().merge(
        ca: '/ca.pem',
        cert: '/cert.pem',
        key: '/key.pem',
      )
    end

    it { is_expected.to compile.with_all_deps }
    it do
      verify_concat_fragment_exact_contents(catalogue, 'qdrouter+ssl_example.conf', [
                                              'ssl-profile {',
                                              '    name: example',
                                              '    ca-cert-file: /ca.pem',
                                              '    cert-file: /cert.pem',
                                              '    private-key-file: /key.pem',
                                              '}',
                                            ],)
    end
  end

  context 'with ssl profile' do
    let(:params) do
      super().merge(
        ca: '/some/where/ca.pem',
        cert: '/some/where/cert.pem',
        key: '/some/where/key.pem',
        ciphers: 'ALL:!aNULL:!MD5:!DSS',
        protocols: ['TLSv1.1', 'TLSv1.2'],
      )
    end

    it { is_expected.to compile.with_all_deps }
    it 'has ssl fragment' do
      verify_concat_fragment_exact_contents(catalogue, 'qdrouter+ssl_example.conf', [
                                              'ssl-profile {',
                                              '    name: example',
                                              '    ca-cert-file: /some/where/ca.pem',
                                              '    cert-file: /some/where/cert.pem',
                                              '    private-key-file: /some/where/key.pem',
                                              '    ciphers: ALL:!aNULL:!MD5:!DSS',
                                              '    protocols: TLSv1.1 TLSv1.2',
                                              '}'
                                            ],)
    end
  end

  context 'with password' do
    let :params do
      super().merge(
        ca: '/ca.pem',
        cert: '/cert.pem',
        key: '/key.pem',
        password: 'secret',
      )
    end

    it { is_expected.to compile.with_all_deps }
    it do
      verify_concat_fragment_exact_contents(catalogue, 'qdrouter+ssl_example.conf', [
                                              'ssl-profile {',
                                              '    name: example',
                                              '    ca-cert-file: /ca.pem',
                                              '    cert-file: /cert.pem',
                                              '    private-key-file: /key.pem',
                                              '    password: secret',
                                              '}',
                                            ],)
    end
  end
end
