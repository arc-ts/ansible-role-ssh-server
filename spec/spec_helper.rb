# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'deep_merge'
require 'serverspec'
require 'net/ssh'
require 'yaml'
require 'yarjuf'

def merge_vars(base_hash:, hash:, merge: 'replace')
  if base_hash.is_a?(Hash) && hash.is_a?(Hash)
    return base_hash.deep_merge!(hash) if merge.casecmp('merge').zero?
    return base_hash.merge!(hash) if merge.casecmp('replace').zero?
  end
  {}
end

set :backend, :ssh

options = Net::SSH::Config.for(host)
options[:host_name] = ENV['KITCHEN_HOSTNAME']
options[:user]      = ENV['KITCHEN_USERNAME']
options[:port]      = ENV['KITCHEN_PORT']
options[:keys]      = ENV['KITCHEN_SSH_KEY']
options[:paranoid]  = false

set :host,        options[:host_name]
set :request_pty, true
set :ssh_options, options
set :env, LANG: 'C', LC_ALL: 'C'

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.failure_exit_code = ENV['RSPEC_FAILURE_EXIT_CODE'] || 1
  if ENV['RSPEC_FORMATTER']
    if ENV['RSPEC_FORMATTER'].casecmp('junit').zero?
      c.output_stream = File.open("#{ENV['KITCHEN_INSTANCE']}.junit.xml", 'w')
      c.add_formatter('JUnit')
    else
      c.add_formatter(ENV['RSPEC_FORMATTER'])
    end
  else
    c.formatter = 'documentation'
  end
end

if ENV['PLAYBOOK']
  playbook = YAML.load_file(ENV['PLAYBOOK'].to_str)
  role_defaults = YAML.load_file('defaults/main.yml')
  hash_behaviour = ENV['HASH_BEHAVIOUR'] || 'replace'
  vars = {}
  vars = merge_vars(base_hash: vars, hash: role_defaults, merge: hash_behaviour)
  playbook.each do |play|
    play.key?('vars') &&
      (vars = merge_vars(base_hash: vars, hash: play['vars'], merge: hash_behaviour))
  end
  if File.exist?('vars/main.yml')
  end
  set_property vars
end
