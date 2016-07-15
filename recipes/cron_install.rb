# Installs a crontab that includes 2 indpendent periodic tasks: 
# pruning and snapshotting elasticsearch indicies


# elasticsearch_user lwrp does not manage home, but this directory
# must exist for cron tasks
directory '/home/elasticsearch' do
  owner 'elasticsearch'
  action :create
end

template '/home/elasticsearch/es_s3_backup.sh' do
  source "es_s3_backup.sh.erb"
  owner "elasticsearch"
end

template '/home/elasticsearch/curator_prune.sh' do
  source "curator_prune.sh.erb"
  owner "elasticsearch"
end

cron 'es_s3_backup' do
  action :create
  minute '0'
  hour '0'
  day '*'
  user 'elasticsearch'
  command "bash /home/elasticsearch/es_s3_backup.sh 2>&1 | /usr/bin/logger -t es_s3_backup"
end

cron 'curator_prune' do
  action :create
  minute '0'
  hour '0'
  day '*'
  user 'elasticsearch'
  command "bash /home/elasticsearch/curator_prune.sh 2>&1 | /usr/bin/logger -t curator_prune"
end