#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
service "nginx" do
  supports :status => true, :start => true, :reload => true, :stop => true
end
service "iptables" do
  supports :status => true, :start => true, :restart => true, :stop => true
end

# Lets install the system packages
packages = ['gcc','openssl-devel','pcre-devel','zlib-devel']
packages.each do |p|
  package "#{p}" do
    action :install
  end
end

remote_file "/tmp/nginx-#{node[:nginx][:version]}.tar.gz" do
  source "#{node[:nginx][:url]}"
  action :create_if_missing
end

bash 'Extract and install NGINX' do
  cwd "/tmp/"
  code <<-EOH
    tar -xvf nginx-#{node[:nginx][:version]}.tar.gz
    (cd nginx-#{node[:nginx][:version]} && ./configure --prefix=#{node[:nginx][:dir]})
    (cd nginx-#{node[:nginx][:version]} && make && make install)
  EOH
  not_if { ::File.exists?("#{node[:nginx][:dir]}/sbin/nginx") }
end

cookbook_file "/etc/init.d/nginx" do
  source "nginx"
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :start, "service[nginx]", :immediately
end

template "#{node[:nginx][:dir]}/conf/nginx.conf" do
  source "nginx.conf.erb"
  action :create
  notifies :reload, "service[nginx]", :immediately
end

cookbook_file "#{node[:nginx][:dir]}/html/index.html" do
  source "index.html"
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :reload, "service[nginx]", :immediately
end

bash "Iptables" do
  code <<-EOH
    iptables -F
    iptables -P INPUT DROP
    iptables -A INPUT -i lo -p all -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
    iptables -A INPUT -j DROP
  EOH
  # notifies :restart, "service[iptables]", :immediately
end
