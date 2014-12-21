#encoding: utf-8
require "net/ssh"
require "net/scp"
desc "remote deploy application."
namespace :remote do
  def encode(data)
    data.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end

  def execute!(ssh, command)
    ssh.exec!(command) do  |ch, stream, data|
      puts "%s:\n%s" % [stream, encode(data)]
    end
  end

  desc "dependency gems"
  task :install => :environment do
    remote_root_path = Setting.remote.app_root_path
    local_config_path  = "%s/config" % ENV["APP_ROOT_PATH"]
    Net::SSH.start(Setting.remote.host, Setting.remote.user, :password => Setting.remote.password) do |ssh|
      ["gem install haml -v 4.0.5",
       "gem install sinatra -v 1.4.5",
       "gem install settingslogic -v 2.0.9",
       "gem install sinatra-contrib -v 1.4.2",
       "gem install sinatra-flash -v 0.3.0",
       "gem install sass -v 3.3.7",
       "gem install unicorn -v 4.8.3",
       "gem install rake -v 10.3.2",
       "gem install net-ssh -v 2.7.0",
       "gem install net-scp 1.2.1",
       "yum install -y tree"
      ].each do |command|
        execute!(ssh, command)
      end
    end
  end

  desc "scp local config files to remote server."
  task :deploy => :environment do
    remote_root_path = Setting.remote.app_root_path
    local_config_path  = "%s/config" % ENV["APP_ROOT_PATH"]
    remote_config_path = "%s/config" % remote_root_path
    yamls = Dir.entries(local_config_path).find_all { |file| File.extname(file) == ".yaml" }
    Net::SSH.start(Setting.remote.host, Setting.remote.user, :password => Setting.remote.password) do |ssh|
      #command = "cd %s && git reset --hard HEAD && git pull" % remote_root_path
      #execute!(ssh, command)
      command = "cd %s && chown -R webmail:webmail ./ && chmod -R 777 ./" % remote_root_path
      execute!(ssh, command)

      # check whether remote server exist yaml file
      yamls.each do |yaml|
        command = "test -f %s/%s && echo '%s - exist' || echo '%s - not found.'" % [remote_config_path, yaml, yaml, yaml]
        execute!(ssh, command)
        ssh.scp.upload!("%s/%s" % [local_config_path, yaml], remote_config_path) do |ch, name, sent, total| 
          print "\rupload #{name}: #{(sent.to_f * 100 / total.to_f).to_i}%"
        end
        puts "\n"
      end
    end
  end
end
