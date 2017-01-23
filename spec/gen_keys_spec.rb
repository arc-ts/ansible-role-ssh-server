# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'spec_helper'
require 'support/config'

if property['ssh_server_gen_keys'] && property['ssh_server_keys']
  RSpec.describe ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
    context 'SSH_SERVER:GEN_KEYS' do
      set_key_defaults
      property['ssh_server_keys'].each do |host_key|
        describe command("ssh-keygen -lf #{host_key['path']}.pub") do
          its(:stdout) do
            is_expected.to match(/#{host_key['bits']}.*\(#{host_key['cipher'].upcase}\)$/)
          end
        end
        describe file(host_key['path']) do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by host_key['owner'] }
          it { is_expected.to be_grouped_into host_key['group'] }
          it { is_expected.to be_mode host_key['mode'].to_i }
        end
        describe file("#{host_key['path']}.pub") do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by host_key['pub_key']['owner'] }
          it { is_expected.to be_grouped_into host_key['pub_key']['group'] }
          it { is_expected.to be_mode host_key['pub_key']['mode'].to_i }
        end
      end
    end
  end
end
