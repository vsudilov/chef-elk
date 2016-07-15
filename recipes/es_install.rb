include_recipe "java::default"

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  type node['elasticsearch']['install_type'].to_sym # since TK can't symbol.
end

elasticsearch_configure "elasticsearch" do
  instance_name node['hostname']
  configuration(
    'cluster.name' => node['elk']['elasticsearch']['cluster_name'],
    'node.name' => node['hostname'],
    'network.host' => "0.0.0.0",
    'discovery.zen.ping.unicast.hosts' => "localhost",
    'discovery.zen.minimum_master_nodes' => node['elk']['elasticsearch']['minimum_master_nodes']
  )
end

elasticsearch_service 'elasticsearch' do
  service_actions [:enable]
end

#http://stackoverflow.com/questions/4764611/java-security-invalidalgorithmparameterexception-the-trustanchors-parameter-mus
#https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
ruby_block "ubuntu-update-ca-certificates" do
  block do
    `update-ca-certificates -f`
  end
  not_if {node['platform'] != "ubuntu"}
end

elasticsearch_plugin 'head' do
  url 'mobz/elasticsearch-head'
  not_if { ::File.exist?('/usr/share/elasticsearch/plugins/head') }
end

elasticsearch_plugin 'cloud-aws' do
  url 'cloud-aws'
  not_if { ::File.exist?('/usr/share/elasticsearch/plugins/cloud-aws') }
end

elasticsearch_plugin 'kopf' do
  url 'lmenezes/elasticsearch-kopf'
  not_if { ::File.exist?('/usr/share/elasticsearch/plugins/kopf') }
end
