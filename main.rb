#!/usr/bin/env ruby
require 'pathname'
require 'rubygems'
require 'ruby-station'; RubyStation.parse_argv
require File.expand_path("src/myrurema", File.dirname(__FILE__))

opt = Options.new(ARGV)
ruremadir = Pathname(RubyStation.data_dir)

if ruremadir.entries.size == 2
  opt.command = :init
  opt.ruremadir = RubyStation.data_dir
  MyRurema.new(opt).run
end

opt.command = :server
opt.ruremadir = RubyStation.data_dir
opt.port = RubyStation.port
MyRurema.new(opt).run
