# Readme

Installs a full ELK stack on 1+ nodes (via `elk::[service]_install` recipies), and manages new nodes entering/leaving the ensemble via the `elk::reconfigure` recipe.

Not that each instance will have an entire ELK stack, although multiple connected instances will form an ElasticSearch cluster.

Test kitchen supported.

** NOTE: All of the default SSL certs are set to the string "FAKE". This is intentional, and will break functionality. Drop your own SSL certs in `templates/default` or use custom attributes to dynamically override. ***

## OpsWorks
  
### Lifecycle

```
    Setup: [java::default]
    Configure: [elk::reconfigure]
    Deploy: [elk::es_install, elk::logstash_install, elk::kibana_install, elk::cron_install]
    Undeploy: []
    Shutdown: []
```
Provisioning occurs through the `elk::[component]_install` recipes.

Version upgrades to individual components should be safe to run by changing the cooresponding attributes and re-running `elk::[component]_install`, but have not been fully tested (TODO).

No special care is necessary for de-provisioning.

### Permissions/IAM

If snapshot/prune is enabled (elk::cron_install is run) This stack (ie instance-profile) requires read+write access to the bucket defined in `node['elk']['elasticsearch']['s3_backup_bucket'] = "my-backup-bucket"`. 

The standard/built-in opsworks-service-role is required for indirect aws-resource management (ELBs, Cloudwatch, Iam:Passrole)

### High-availability
This implementation achieves HA by registering all instances behind an ELB. A failure in a single instance will not trigger an outage.

### Scale
This implementation scales horizontally by leverging elasticsearch's built-in clustering support. Instances can be added and removed from the fleet dynamically, limited only by the limitiations of ElasticSearch. No downtime is required for these operations.

## What is all this? Just give me ELK!

If understanding the details about what's happening aren't a priority at the moment, follow these instructions on your target machine to set up a single node ELK:

  1. Install chef-dk (https://downloads.chef.io/chef-dk/)
  1. `git clone`
  1. `cd chef-elk/`
  1. `berks vendor cookbooks && cd cookbooks/` 
  1. `chef-client -z -o elk::es_install,elk::logstash_install,elk::kibana_install,elk::reconfigure`

## Attributes

  - `node['java']['jdk_version'] = 8`
  - `node['elasticsearch']['version'] = '2.3.0'`
  - `node['elasticsearch']['install_type'] = :package`
  - `node['elk']['elasticsearch']['cluster_name'] = "my-es-cluster"`
  - `node['elk']['elasticsearch']['s3_backup_bucket'] = "my-backup-bucket"`
  - `node['elk']['elasticsearch']['visibility_period_days'] = 10`
   
  - `node['elk']['kibana']['nginx']['ssl_cert'] = nil  #nginx serves on :443 SSL, leave these as `nil` to use built-in self-signed certs`
  - `node['elk']['kibana']['nginx']['ssl_key'] = nil`
  - `node['elk']['kibana']['nginx']['htaccess'] = ["admin:$apr1$w/E23yd.$ylUt5OvroZKZrapOPsvZj1"]  #nginx basic auth: Default username/password is admin/password; use htpasswd to generate new logins and override this attribute`

Should be N/2+1 to prevent splitbrain scenarios, where N is the number of nodes in your cluster
  - `node['elk']['elasticsearch']['minimum_master_nodes'] = 1`

Doesn't really matter, but should be more than 1 for a cluster deployment. These are the gossip routers that other elasticsearch nodes talk to.
  - `node['elk']['elasticsearch']['discovery']['gossip_hosts_count'] = 2`

We're using Chef::Search to find other nodes (default find every other node)
  - `node['elk']['elasticsearch']['discovery']['search_query'] = "ipaddress:*"`

Logstash config:
  - `node['elk']['logstash']['conf']['input']`
  - `node['elk']['logstash']['conf']['output']`
  - `node['elk']['logstash']['conf']['filter']`

Logstash, Kibana installation info
  - `node['elk']['kibana']['version'] = "4.5.0-linux-x64"`
  - `node['elk']['kibana']['url'] = 'https://download.elastic.co/kibana/kibana/kibana-4.5.0-linux-x64.tar.gz'`
  - `node['elk']['kibana']['sha256'] = 'fa3f675febb34c0f676f8a64537967959eb95d2f5a81bc6da17aa5c98b9c76ef'`

  - `node['elk']['logstash']['version'] = "2.3.0"`
  - `node['elk']['logstash']['url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-2.3.0.tar.gz'`
  - `node['elk']['logstash']['sha256'] = 'd802803ac6dc7e9215b19764dd8fbaa74c75fa1d8bf387508fb0d0d8d36b0241'`

## TODO:
  - Version upgrade support+tests
  - Improve organization of templates in `templates/`
