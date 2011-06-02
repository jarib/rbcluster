require 'mkmf'

$CFLAGS << " #{ENV["CFLAGS"]}"
RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

create_makefile "rbcluster"