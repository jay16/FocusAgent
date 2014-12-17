#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

$:.unshift(File.dirname(__FILE__))

task :default => [:simple]

desc "set up environment for rake"
task :environment => "Gemfile.lock" do
  require File.expand_path('../config/boot.rb', __FILE__)
  eval "Rack::Builder.new {( " + File.read(File.expand_path('../config.ru', __FILE__)) + "\n )}"
end

task :simple do
  require "settingslogic"
  @options ||= {}
  @options[:rack_env] = ENV["RACK_ENV"] ||= "test"
  ENV["APP_ROOT_PATH"] = @options[:app_root_path] = Dir.pwd
  load "%s/app/models/setting.rb" % @options[:app_root_path]

  def execute!(shell, whether_show_log = false)
    _result = IO.popen(shell) do |stdout| 
      stdout.reject(&:empty?) 
    end.unshift($?.exitstatus.zero?)
    if !_result[0] or whether_show_log
      _shell  = shell.gsub(@options[:app_root_path], "=>").split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      _status = _result[0]
      _res    = _result[1..-1].map { |line| "\t\t" + line }.join if _result.length > 1 
      puts "%s\n\t\t==> %s\n%s\n" % [_shell, _status, _res]
    end
    return _result
  end 

  @options[:os_platform] = `test -f /etc/issue && cat /etc/issue | head -n 1 || uname -s`.to_s.strip
  @options[:command_md5] = case @options[:os_platform]
  when "Linux"  then Setting.command.linux.md5
  when "Darwin" then Setting.command.darwin.md5
  else Setting.command.linux.md5
  end

  def base_on_root_path(path)
    if @options.has_key?(:app_root_path)
      File.join(@options[:app_root_path], path)
    else
      raise "[dangerous] @options missing key - :app_root_path"
    end
  end

  @options.merge!({
    :timestamp           => Time.now.strftime("%Y%m%d"),
    :server_ip           => Setting.server.ip,
    :pool_wait_path      => base_on_root_path(Setting.pool.wait),
    :pool_download_path  => base_on_root_path(Setting.pool.download),
    :pool_emails_path    => base_on_root_path(Setting.pool.emails),
    :pool_archived_path  => base_on_root_path(Setting.pool.archived),
    :pool_data_path      => base_on_root_path(Setting.pool.data),
    :pool_mailtest_path  => base_on_root_path(Setting.pool.mailtest),
    :server_path_download=> Setting.server.path.download,
    :server_path_mailtest=> Setting.server.path.mailtest,
    :mg_wait_path        => Setting.mailgates.path.wait,
    :mg_log_path         => Setting.mailgates.path.log,
    :mg_archived_path    => Setting.mailgates.path.archived
  })
end

Dir.glob('lib/tasks/*.rake').each { |file| load file }
