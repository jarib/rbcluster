# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rbcluster/version"

Gem::Specification.new do |s|
  s.name        = "rbcluster"
  s.version     = Cluster::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken", "Michiel Jan Laurens de Hoon"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = "http://bonsai.hgc.jp/~mdehoon/software/cluster/software.htm"
  s.summary     = %q{Ruby bindings for the Cluster C library}
  s.description = %q{This gem provides a Ruby extension to the clustering routines in the C Clustering Library (which also backs e.g. Python's pycluster and Perl's Algorithm::Cluster).}

  s.rubyforge_project = "rbcluster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.extensions    = `git ls-files -- ext/**/extconf.rb`.split("\n")

  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec", "~> 2.6.0"
end
