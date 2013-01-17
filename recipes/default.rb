#
# Cookbook Name:: nix
# Recipe:: default
#
# Copyright 2012, Knewton, Apache 2.0
#

key = "nix-#{node['nix']['version']}" +
  "-#{node['platform']}-#{node['platform_version']}" + 
  "-#{node['kernel']['machine']}.tar.bz2"

env = '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'

bash 'download & extract nix' do
  code    "s3-get -e stack_iam -b knewton-utility-build #{key}|tar oxj -C /"
  creates env
end

link '/etc/profile.d/nix.sh' do
  to env
end
