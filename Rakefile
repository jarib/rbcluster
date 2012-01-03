include Rake::DSL if defined?(Rake::DSL)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/extensiontask'
Rake::ExtensionTask.new do |ext|
  ext.name     = "rbcluster"
  ext.lib_dir  = "lib/rbcluster"
  ext.ext_dir  = "ext/rbcluster"
  ext.gem_spec = eval(File.read("./rbcluster.gemspec"))
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => [:compile, :spec]