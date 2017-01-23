# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'

def version_cmd
  return 'dpkg-query -W openssh-server' if %w(debian ubuntu).include?(os[:family])
  return 'rpm -q --info openssh-server | grep Version' if %w(redhat).include?(os[:family])
end

RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
  context 'SSH_SERVER:INSTALL' do
    describe 'ssh-server package' do
      subject { package('openssh-server') }
      it { is_expected.to be_installed }
      if property['ssh_server_version']
        context 'version' do
          subject { command(version_cmd) }
          its(:stdout) { is_expected.to match(property['ssh_server_version']) }
        end
      end
    end
  end
end
