name = node.hostname
include_recipe 'runit::default'

logstash_instance name do
  action :create
  version node['elk']['logstash']['version']
  source_url node['elk']['logstash']['url']
  checksum node['elk']['logstash']['sha256']
end

template "/etc/ca.crt" do
  source "beats.ca.erb"
  owner "logstash"
  group "logstash"
  mode "0400"
end

template "/etc/server.crt" do
  source "beats.cert.erb"
  owner "logstash"
  group "logstash"
  mode "0400"
end

template "/etc/server.key" do
  source "beats.key.erb"
  owner "logstash"
  group "logstash"
  mode "0400"
end

logstash_service name do
  action [:enable]
  templates_cookbook "elk"
end

logstash_config name do
  action 'create'
  templates_cookbook "elk"
  templates "logstash" => 'logstash/config/logstash.conf.erb'
  notifies :restart, "logstash_service[#{name}]", :delayed
end

logstash_curator name do
  action [:create]
end

logstash_plugins 'logstash-input-beats' do
  action [:create]
  instance name
end