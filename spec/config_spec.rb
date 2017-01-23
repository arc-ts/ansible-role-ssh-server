require 'spec_helper'
require 'support/config'
# rubocop:disable Metrics/BlockLength
RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
  context 'SSH_SERVER:CONFIG' do
    set_os_defaults
    describe 'ssh-server config file' do
      subject { file(property['ssh_server_config_file']['path']) }
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by property['ssh_server_config_file']['owner'] }
      it { is_expected.to be_grouped_into property['ssh_server_config_file']['group'] }
      it { is_expected.to be_mode property['ssh_server_config_file']['mode'].to_i }
      property['ssh_server_config'].each do |key, value|
        if value.instance_of?(Array)
          value.each do |opt|
            its(:content) { is_expected.to match(/#{key} #{opt}/) }
          end
        else
          its(:content) { is_expected.to match(/#{key} #{value}/) }
        end
      end
    end
    describe 'ssh-server environment file' do
      subject { file(property['ssh_server_env_file']['path']) }
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by property['ssh_server_env_file']['owner'] }
      it { is_expected.to be_grouped_into property['ssh_server_env_file']['group'] }
      it { is_expected.to be_mode property['ssh_server_env_file']['mode'].to_i }
      property['ssh_server_env'].each do |key, value|
        its(:content) { is_expected.to match(/#{key}=#{value}/) }
      end
    end
    describe 'ssh-server service' do
      subject { service(property['_ssh_server_service_name']) }
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
# rubocop:enable Metrics/BlockLength
