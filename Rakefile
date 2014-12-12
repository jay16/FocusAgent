#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

$:.unshift(File.dirname(__FILE__))

task :default => [:environment]

desc "set up environment for rake"
task :environment => "Gemfile.lock" do
  require File.expand_path('../config/boot.rb', __FILE__)
  eval "Rack::Builder.new {( " + File.read(File.expand_path('../config.ru', __FILE__)) + "\n )}"
end

task :simple do
  require "settingslogic"
  ENV["APP_ROOT_PATH"] = root = Dir.pwd
  ENV["RACK_ENV"] = "development"
  load "%s/app/models/setting.rb" % root

  def execute!(shell)
    puts shell
    IO.popen(shell) do |stdout| 
      stdout.reject(&:empty?) 
    end.unshift($?.exitstatus.zero?)
  end 
end

Dir.glob('lib/tasks/*.rake').each { |file| load file }
