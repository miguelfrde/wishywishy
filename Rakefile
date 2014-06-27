require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  ENV['RACK_ENV'] = 'localtest'
end

RSpec::Core::RakeTask.new('spec:remote') do |spec|
  ENV['RACK_ENV'] = 'remotetest'
end

desc 'serve app using rerun and foreman'
task :serve do
  sh 'rerun foreman start'
end

task :default => :serve
