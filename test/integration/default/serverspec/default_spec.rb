require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "elasticsearch service" do
  it "is enabled" do
    expect(service("elasticsearch")).to be_enabled
  end

  it "is running" do
    expect(service("elasticsearch")).to be_running.under('init')
  end  

  it "is listening on port 9200" do
    expect(port(9200)).to be_listening
  end  

  it "should have plugin: head" do
    expect(file('/usr/share/elasticsearch/plugins/head')).to be_directory
  end

  it "should have plugin: cloud-aws" do
    expect(file('/usr/share/elasticsearch/plugins/cloud-aws')).to be_directory
  end

  it "should have an elasticsearch.yml config that contains non-default values" do
    loc = "/etc/elasticsearch/elasticsearch.yml"
    expect file(loc).content {should contain 'discovery.zen.ping.multicast.enabled: false'}
    expect file(loc).content {should contain 'discovery.zen.minimum_master_nodes: 1'}
    expect file(loc).content {should contain 'network.host: 0.0.0.0'}
  end
end


describe "logstash service" do
  it "is running" do
    name = "logstash_#{host_inventory['hostname']}"
    expect(service(name)).to be_running.under('runit')
  end

  it "should have a logstash config" do
    loc = "/opt/logstash/#{host_inventory['hostname']}/etc/conf.d/logstash"
    expect(file(loc)).to be_file
  end
end


describe "kibana service" do
  it "is running" do
    expect(service("kibana")).to be_running.under('runit')
  end

  it "is listening on port 5602" do
    expect(port(5601)).to be_listening
  end
end

describe "nginx service" do
  it "is running" do
    expect(service("nginx")).to be_running.under('runit')
  end

  it "is listening on port 443" do
    expect(port(443)).to be_listening
  end

  it "should have an .htpasswd file" do
    expect(file("/etc/nginx/.htpasswd")).to be_file
  end

  it "should have basicauth enabled" do
    expect file("/etc/nginx/sites-enabled/kibana").content {should contain 'auth_basic_user_file /etc/nginx/.htpasswd;'}
  end

  it "should have ssl enabled" do
    expect file("/etc/nginx/sites-enabled/kibana").content {should contain 'ssl on;'}
  end

end

describe cron do
  it { should have_entry('0 0 * * * bash /home/elasticsearch/es_s3_backup.sh 2>&1 | /usr/bin/logger -t es_s3_backup').with_user('elasticsearch') }
  it { should have_entry('0 0 * * * bash /home/elasticsearch/curator_prune.sh 2>&1 | /usr/bin/logger -t curator_prune').with_user('elasticsearch') }
end