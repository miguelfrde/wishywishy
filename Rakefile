require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'serve app using rerun and foreman'
task :serve do
  sh 'rerun foreman start'
end

task :default => :serve
