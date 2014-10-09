#
# Cookbook Name:: galaxy
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
user "galaxy" do
    username node[:galaxy][:user]
    home     node[:galaxy][:home]
    shell    node[:galaxy][:shell]
    password node[:galaxy][:password]

    supports :manage_home => true
    action   :create
end
# set directory owner and permission mainly for shared file system
directory node[:galaxy][:home] do
    owner node[:galaxy][:user]
    group      node[:galaxy][:group]
    mode '0755'
end

include_recipe "python"
# install drmaa for gridengine
python_pip "drmaa" do
    action :install
end

include_recipe "mercurial"
mercurial node[:galaxy][:path] do
    repository node[:galaxy][:repository]
    owner      node[:galaxy][:user]
    group      node[:galaxy][:group]
    reference  node[:galaxy][:reference]

    action     :clone
end

template "/etc/init.d/galaxy" do
    owner      "root"
    group      "root"
    mode       "0755"
    source     "galaxy.init.erb"

    action     :create
end
bash "add_galaxy_service" do
    code <<-EOL
        chkconfig --add galaxy
    EOL
end
service "galaxy" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end


