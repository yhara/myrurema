#
# Rakefile to creating gems
#
# configurations:
PROJECT_NAME = File.basename(File.dirname(__FILE__))

begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "#{PROJECT_NAME}"
  gemspec.summary = "A tool for Rurema (the new Japanese Ruby reference manual)"
  gemspec.email = "yutaka.hara/at/gmail.com"
  gemspec.homepage = "http://github.com/yhara/#{PROJECT_NAME}"
  gemspec.description = gemspec.summary
  gemspec.authors = ["Yutaka HARA"]
  gemspec.executables = ["rurema"]
end

desc "install current source as a gem"
task :dogfood => [:gemspec, :build] do
  sh "gemi pkg/#{PROJECT_NAME}-#{File.read("VERSION").chomp}.gem"
end

desc "uninstall the installed gem"
task :undogfood do
  sh "gemi -u #{PROJECT_NAME}"
end

desc "uninstall, then install current source as gem"
task :redogfood => [:undogfood, :dogfood]
