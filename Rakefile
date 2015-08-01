require 'date'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :backup do
  snapshot_name = Time.now.strftime('%Y-%m-%d')
  sh "curl -XPUT 'http://localhost:9200/_snapshot/s3_repository/snapshot-#{snapshot_name}'"
end

task :default => :spec