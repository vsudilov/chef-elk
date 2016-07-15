default['java']['jdk_version'] = 8

default['nginx']['install_method'] = 'source' # upstream recipe quirkiness
default['nginx']['version']  = '1.9.9'
default['nginx']['source']['version'] = '1.9.9' # upstream recipe quirkiness
default['nginx']['source']['url'] = "http://nginx.org/download/nginx-1.9.9.tar.gz"
default['nginx']['source']['checksum'] = 'de66bb2b11c82533aa5cb5ccc27cbce736ab87c9f2c761e5237cda0b00068d73'
default['nginx']['init_style'] = 'runit'
default['logstash']['instance_default']['xms'] = "256M"
default['logstash']['instance_default']['xmx'] = "1024M"
default['logstash']['instance_default']['workers'] = 2


default['elasticsearch']['version'] = '2.3.0'
default['elasticsearch']['install_type'] = :package

# version and url should expliticly match
default['elk']['kibana']['version'] = "4.5.0-linux-x64"
default['elk']['kibana']['url'] = 'https://download.elastic.co/kibana/kibana/kibana-4.5.0-linux-x64.tar.gz'
default['elk']['kibana']['sha256'] = 'fa3f675febb34c0f676f8a64537967959eb95d2f5a81bc6da17aa5c98b9c76ef'
default['elk']['kibana']['config']['port'] = 5601

default['elk']['kibana']['nginx']['ssl_cert'] = nil
default['elk']['kibana']['nginx']['ssl_key'] = nil
# Default username/password is admin/password; use htpasswd to generate new logins
default['elk']['kibana']['nginx']['htaccess'] = [
	"admin:$apr1$w/E23yd.$ylUt5OvroZKZrapOPsvZj1",
]

# version and url should expliticly match
default['elk']['logstash']['version'] = "2.3.0"
default['elk']['logstash']['url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-2.3.0.tar.gz'
default['elk']['logstash']['sha256'] = 'd802803ac6dc7e9215b19764dd8fbaa74c75fa1d8bf387508fb0d0d8d36b0241'

default['elk']['elasticsearch']['cluster_name'] = "my-es-cluster"
default['elk']['elasticsearch']['minimum_master_nodes'] = 1
default['elk']['elasticsearch']['discovery']['gossip_hosts_count'] = 2
default['elk']['elasticsearch']['discovery']['search_query'] = "ipaddress:*"
default['elk']['elasticsearch']['s3_backup_bucket'] = "my-backup-bucket"
default['elk']['elasticsearch']['visibility_period_days'] = 10

default['elk']['logstash']['conf']['beats']['ssl_ca'] = nil
default['elk']['logstash']['conf']['beats']['ssl_cert'] = nil
default['elk']['logstash']['conf']['beats']['ssl_key'] = nil
default['elk']['logstash']['conf']['input'] = 'beats {
    port => 6000
    ssl => true
    ssl_certificate_authorities => ["/etc/ca.crt"]
    ssl_certificate => "/etc/server.crt"
    ssl_key => "/etc/server.key"
    ssl_verify_mode => "force_peer"
  }'

default['elk']['logstash']['conf']['output'] = 	'elasticsearch {
	hosts => "localhost:9200"
  }'

default['elk']['logstash']['conf']['filter'] = ''
