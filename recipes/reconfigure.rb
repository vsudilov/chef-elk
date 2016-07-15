require 'yaml'

include_recipe 'elk::es_install'

begin
  f = YAML.load_file("/etc/elasticsearch/elasticsearch.yml")
  current_seeds = f['discovery.zen.ping.unicast.hosts'].split(',').length
  expected = node['elk']['elasticsearch']['discovery']['gossip_hosts_count']
  if current_seeds >= expected
          Chef::Log.info("Skipping restart since there are #{current_seeds}>=#{expected} seeds in cassandra.yml")
          _notify = :nothing
  else
          Chef::Log.info("Setting restart signal for elasticsearch")
          _notify = :restart
  end
rescue Errno::ENOENT
  Chef::Log.warn("elasticsearch.yml not found; this is expected from running elk::reconfigure as part of the initial provisioning")
  _notify = :restart
end

elasticsearch_configure "elasticsearch" do
  instance_name node['hostname']
  configuration(
    'cluster.name' => node['elk']['elasticsearch']['cluster_name'],
    'node.name' => node['hostname'],
    'network.host' => "0.0.0.0",
    'discovery.zen.ping.unicast.hosts' => discover_nodes,
    'discovery.zen.ping.multicast.enabled' => false,
    'discovery.zen.minimum_master_nodes' => node['elk']['elasticsearch']['minimum_master_nodes']
  )
  notifies _notify, "elasticsearch_service[elasticsearch]", :delayed 
end