#!/usr/bin/env ruby
require 'pathname'
require 'rubygems'
require 'ruby-station'; RubyStation.parse_argv
require 'bin/rurema'

ruremadir = Pathname(RubyStation.data_dir)
if ruremadir.entries.size == 2
  args = ARGV + %w(--init --ruremadir=#{RubyStation.data_dir})
  MyRurema.new(Options.new(args).run)
end
args = ARGV + %w(--server --port=#{RubyStation.port} --ruremadir=#{RubyStation.data_dir})
MyRurema.new(Options.new(args).run)
