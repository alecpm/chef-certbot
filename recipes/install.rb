#
# Cookbook Name:: certbot
# Recipe:: install
#
# Copyright 2016 Inviqa UK Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if node['certbot']['install_method'] == 'package'
  include_recipe 'yum-epel' if platform_family?('rhel')

  apt_repository node['certbot']['apt_repository']['name'] do
    node['certbot']['apt_repository'].each do |key, value|
      send key, value
    end
  end if node['certbot']['apt_repository']
end

case node['certbot']['install_method']
when 'package'
  package node['certbot']['package']
when 'certbot-auto'
  remote_file node['certbot']['bin'] do
    action :create_if_missing
    atomic_update false
    source ['https://dl.eff.org/certbot-auto', 'https://raw.githubusercontent.com/certbot/certbot/v0.37.1/letsencrypt-auto-source/letsencrypt-auto']
    mode 0755
    use_conditional_get false
  end

  # run certbot-auto to install its dependencies
  execute "'#{node['certbot']['bin']}' --os-packages-only --non-interactive"
end
