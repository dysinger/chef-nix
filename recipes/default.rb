# Copyright 2013, Knewton, Apache 2.0 License

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed
# with this work for additional information regarding copyright
# ownership.  The ASF licenses this file to you under the Apache
# License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License.  You may obtain a copy of the
# License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.

# NIX INSTALL

bash 'nix install' do
  code "wget -O- #{node['nix']['url']}|tar xj -C /"
  creates '/nix/store'
end

bash 'nix finish install' do
  cwd '/root'
  code 'sudo -i /usr/bin/nix-finish-install'
  creates '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
end

link '/etc/profile.d/nix.sh' do
  to '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
end

# SHELL & BUILD GROUP & USERS FOR NIX

execute 'echo "/bin/false"|tee -a /etc/shells' do
  not_if 'grep false /etc/shells'
end

(1..10).each do |i|
  user "nixbld#{i}" do
    system true
    group 'nogroup'
    home  '/var/empty'
    shell '/bin/false'
  end
end

group 'nixbld' do
  system true
  members (1..10).collect {|i| "nixbld#{i}"}
end

# FOLDER PERMISSIONS

directory '/nix/store' do
  recursive true
  owner 'root'
  group 'nixbld'
  mode  '1775'
end

directory '/nix/var/nix/profiles' do
  recursive true
  owner 'root'
  group 'root'
  mode  '1777'
end

directory '/nix/var/nix/profiles/per-user' do
  recursive true
  owner 'root'
  group 'root'
  mode  '1777'
end

# NIX DAEMON

directory '/etc/nix'

file '/etc/nix/nix.conf' do
  content 'build-users-group = nixbld'
end

file '/etc/profile.d/nix-worker.sh' do
  content 'export NIX_REMOTE=daemon'
end

file '/etc/profile.d/nix-defexpr.sh' do
  content '[ ! -e $HOME/.nix-defexpr ] && mkdir $HOME/.nix-defexpr'
end

cookbook_file '/etc/init/nix-worker.conf'

service 'nix-worker' do
  provider Chef::Provider::Service::Upstart
  action [ :start ]
end
