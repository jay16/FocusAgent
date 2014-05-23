require "rubygems"
require "fileutils"

ENV["APP_NAME"] ||= "focus_mail_agent"
ENV["RACK_ENV"] ||= "development"

begin
  ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__) 
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
Bundler.require(:default, ENV["RACK_ENV"])

ENV["APP_ROOT_PATH"] = File.expand_path("../../", __FILE__)
ENV["VIEW_PATH"] = File.join(ENV["APP_ROOT_PATH"], "app/views")

# basic dirctory config
`cd #{ENV["APP_ROOT_PATH"]} && mkdir -p public/{wget_pool,wget_file,wget_bak}`
`cd #{ENV["APP_ROOT_PATH"]} && test -d log || mkdir log`

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$:.unshift(File.join(ENV["APP_ROOT_PATH"],"config"))
$:.unshift(File.join(ENV["APP_ROOT_PATH"],"lib/tasks"))
%w(controllers helpers models).each do |path|
  $:.unshift(File.join(ENV["APP_ROOT_PATH"],"app",path))
end

# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "asset-handler"
require "form-helpers"

# application must be first
# other controller base on it
controllers = Dir.entries(File.join(ENV["APP_ROOT_PATH"],"app/controllers"))
  .grep(/_controller\.rb$/).map { |f| f.sub("_controller.rb","") }
tmp_index = controllers.index("application")
controllers[tmp_index] = controllers[0] 
controllers[0] = "application"
# helper在controller中被调用，优先于controller
controllers.each { |part| require "#{part}_helper" }
# controller,基类application_controller.rb
# application_controller.rb最先被引用
controllers.each { |part| require "#{part}_controller" }

ENV["OS_PLATFORM"] = `test -f /etc/issue && cat /etc/issue | head -n 1 || uname -s`.to_s.strip
ENV["OS_HOSTNAME"] = `hostname`.to_s.strip


`chown -R #{Settings.mailgates.user}:#{Settings.mailgates.group} #{ENV["APP_ROOT_PATH"]}`
`chmod -R #{Settings.mailgates.mode} #{ENV["APP_ROOT_PATH"]}`


# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

def kill_agent_process_if_exist(script_file, pid_file)
  if File.exist?(pid_file) and !(lines = IO.readlines(pid_file)).empty?
      pid = lines[0].strip
      ps = "ps aux | grep #{pid} | grep -v 'grep'"
      puts "execute shell - #{ps}"
      status, *result = run_command(ps)
      if status and result.join.include?(script_file)
        `kill -9 #{pid}`
        status, *result = run_command(ps)
        puts (result.empty? ? "kill -p #{pid} successfully!" : "fail kill -9 #{pid} - #{result.join}")
      else
        warn "pid #{pid} not found - #{result.join}"
      end
  else
    warn "pid_file not found - #{pid_file}"
  end
end

tmp_path = File.join(ENV["APP_ROOT_PATH"],"tmp")
script_path = File.join(ENV["APP_ROOT_PATH"],"lib/script")
%w(agent_wget agent_mv2wait).each do |p|
  script_file = File.join(script_path, [p, "rb"].join("."))
  pid_file    = File.join(tmp_path, [p, "pid"].join("."))

  # kill exist old agent process 
  # before startup new agent process
  kill_agent_process_if_exist(script_file, pid_file)

  if p == "agent_wget"
  #    system "nohup ruby #{script_file} #{Settings.mailgates.speed} #{Settings.mailgates.wait_path} &"
  end
end

# run this then startup successfully
# record start log in log/startup.log
tmp_title = "timestamp, action, plantform, hostname"
tmp_str   = [Time.now.strftime("%Y-%m-%d %H:%M:%S"), "start", ENV["OS_PLATFORM"], ENV["OS_HOSTNAME"]].join(", ")
log_path = "log/startup.log"
`cd #{ENV["APP_ROOT_PATH"]} && test -f #{log_path} || echo "#{tmp_title}" > #{log_path}`
`cd #{ENV["APP_ROOT_PATH"]} && echo "#{tmp_str}" >> #{log_path}`
