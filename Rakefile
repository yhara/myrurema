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
  sh "sudo gem install pkg/#{PROJECT_NAME}-#{File.read("VERSION").chomp}.gem"
end

desc "uninstall the installed gem"
task :undogfood do
  sh "sudo gem uninstall #{PROJECT_NAME}"
end

desc "uninstall, then install current source as gem"
task :redogfood => [:undogfood, :dogfood]

desc "uninstall temporary gem and install from github"
task :nodogfood do
  sh "sudo gem uninstall #{PROJECT_NAME}"
  sh "sudo gem install yhara-#{PROJECT_NAME}"
end

desc "check for gem to be built"
task :stalk do
  sh "gemstalk yhara #{PROJECT_NAME}"
end
