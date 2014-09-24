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

include_recipe "python"
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

# install and setting tmux
include_recipe "yum"
## add the EPEL repo
yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
  gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'
  action :create
end
package "tmux"
template "/.tmux.conf" do
        path "/.tmux.conf"
        source "tmux.conf.erb"
        owner "root"
        group "root"
        mode 0644
end

# install and setting nginx
package "nginx"
service "nginx" do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end
template "/etc/nginx/conf.d/default.conf" do
        path "/etc/nginx/conf.d/default.conf"
        source "nginx.conf.erb"
        owner "root"
        group "root"
        mode 0644
        notifies :reload,'service[nginx]'
end

# install wget
package "wget"

# install vim
include_recipe "vim"
