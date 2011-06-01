require 'mkmf'

$CFLAGS << " #{ENV["CFLAGS"]}"
create_makefile "rbcluster"