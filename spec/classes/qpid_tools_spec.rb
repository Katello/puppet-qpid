require 'spec_helper'

describe 'qpid::tools' do
  on_supported_os.each do |_os, facts|
    context 'on redhat' do
      let :facts do
        facts
      end

      context 'without parameters' do
        it { is_expected.to contain_package('qpid-tools').with_ensure('present') }
      end

      context 'with ensure absent' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to contain_package('qpid-tools').with_ensure('purged') }
      end
    end
  end
end
