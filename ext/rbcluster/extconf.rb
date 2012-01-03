require 'mkmf'

$CFLAGS << " #{ENV["CFLAGS"]} -std=c99"
RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

create_makefile "rbcluster/rbcluster"