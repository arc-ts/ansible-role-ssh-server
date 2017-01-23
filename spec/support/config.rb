# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'yaml'
require 'spec_helper'

def distrib_name
  return 'centos' if host_inventory['platform'] == 'redhat'
  host_inventory['platform'].downcase
end

def distrib_major_version
  host_inventory['platform_version'].split('.')[0]
end

def load_os_vars
  YAML.load_file("vars/#{distrib_name}_#{distrib_major_version}.yml")
end

def update_prop_def(vars, key, default)
  property[key] = (vars[default]).merge(property[key] || {})
end

def set_os_defaults
  os_vars = load_os_vars
  property['_ssh_server_bin_path'] = os_vars['_ssh_server_bin_path']
  property['_ssh_server_service_name'] = os_vars['_ssh_server_service_name']
  update_prop_def(os_vars, 'ssh_server_config', '_ssh_server_config_defaults')
  update_prop_def(os_vars, 'ssh_server_config_file', '_ssh_server_config_file_defaults')
  update_prop_def(os_vars, 'ssh_server_env', '_ssh_server_env_defaults')
  update_prop_def(os_vars, 'ssh_server_env_file', '_ssh_server_env_file_defaults')
end

def set_key_defaults
  os_vars = load_os_vars
  keys = []
  property['ssh_server_keys'].each do |key_spec|
    keys << os_vars['_ssh_server_key_defaults'].merge(key_spec)
  end
  property['ssh_server_keys'] = keys
end
