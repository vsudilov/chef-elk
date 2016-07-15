kibana_user 'kibana' do
  name 'kibana'
  group 'kibana'
  home '/opt/kibana'
end

kibana_install 'file' do
  name 'web'
  user 'kibana'
  group 'kibana'
  version node['elk']['kibana']['version']
  file_url node['elk']['kibana']['url']
  file_checksum node['elk']['kibana']['sha256']
  install_dir '/opt/kibana'
  install_type 'file'
end

template '/opt/kibana/current/config/kibana.yml' do
  cookbook 'kibana_lwrp'
  mode '0644'
  user 'kibana'
  group 'kibana'
  variables(
    index: node['kibana']['config']['kibana_index'],
    port: node['elk']['kibana']['config']['port'],
    elasticsearch: "http://127.0.0.1:9200",
    default_route: node['kibana']['config']['default_route'],
    panel_names:  node['kibana']['config']['panel_names'],
    default_app_id: node['kibana']['config']['default_app_id']
  )
end

include_recipe 'runit::default'

runit_service 'kibana' do
    options(
      user: 'kibana',
      home: "/opt/kibana/current"
    )
    cookbook 'kibana_lwrp'
    subscribes :restart, "template[/opt/kibana/current/config/kibana.yml]", :delayed
end

node.set['nginx']['default_site_enabled'] = false
include_recipe 'nginx'
user "nginx"

template "/etc/nginx/sites-available/kibana" do
  variables(
    server_name: "kibana",
    listen_address: "0.0.0.0",
    listen_port: "443",
    kibana_port: node['elk']['kibana']['config']['port']
  )
  source "kibana-nginx.conf.erb"
  notifies :reload, 'service[nginx]', :delayed
end

template '/etc/nginx/.htpasswd' do
  source 'htpasswd.erb'
  owner 'nginx'
  group 'nginx'
  mode '0400'
  notifies :reload, 'service[nginx]', :delayed
end

template '/etc/nginx/cert.crt' do
  source 'nginx.cert.crt.erb'
  owner 'nginx'
  group 'nginx'
  mode '0400'
  notifies :reload, 'service[nginx]', :delayed
end

template '/etc/nginx/cert.key' do
  source 'nginx.cert.key.erb'
  owner 'nginx'
  group 'nginx'
  mode '0400'
  notifies :reload, 'service[nginx]', :delayed
end

nginx_site 'kibana'