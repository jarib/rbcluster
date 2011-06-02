require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/extensiontask'
Rake::ExtensionTask.new "rbcluster", eval(File.read("./rbcluster.gemspec"))

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => [:compile, :spec]