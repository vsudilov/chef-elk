def discover_nodes
	q = node['elk']['elasticsearch']['discovery']['search_query']
	Chef::Log.info("Querying for nodes using #{q}")
	xs = search(:node, q).map(&:ipaddress).sort.uniq
	Chef::Log.info("Query returned nodes #{xs}")
	if xs.empty?
		[node['ipaddress']]
	else
		xs.take(node['elk']['elasticsearch']['discovery']['gossip_hosts_count'])
	end
end
