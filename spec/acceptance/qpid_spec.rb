require 'spec_helper_acceptance'

describe 'qpid', order: :defined do
  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        include qpid
        PUPPET
      end
    end

    describe service('qpidd') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port('5672') do
      it { is_expected.to be_listening }
    end

    describe package('qpid-tools') do
      it { is_expected.to be_installed }
    end

    describe file('/var/lib/qpidd') do
      it { is_expected.to be_directory }
    end
  end

  context 'with ensure absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'qpid':
          ensure => 'absent',
        }
        PUPPET
      end
    end

    describe service('qpidd') do
      it { is_expected.not_to be_running }
      it { is_expected.not_to be_enabled }
    end

    describe port('5672') do
      it { is_expected.not_to be_listening }
    end

    describe package('qpid-tools') do
      it { is_expected.not_to be_installed }
    end

    describe file('/var/lib/qpidd') do
      it { is_expected.not_to exist }
    end
  end
end
