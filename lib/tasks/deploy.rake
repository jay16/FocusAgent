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
      puts "%s: %s" % [stream, encode(data)]
    end
  end

  desc "scp local config files to remote server."
  task :deploy => :environment do
    remote_root_path = Setting.remote.app_root_path
    local_config_path  = "%s/config" % ENV["APP_ROOT_PATH"]
    remote_config_path = "%s/config" % remote_root_path
    yamls = Dir.entries(local_config_path).find_all { |file| File.extname(file) == ".yaml" }
    [4].each do |index|
      agent = "mg0%s." % index
      host  = agent+Setting.remote.host
      puts ""
      puts "="*10
      puts "deal with %s" % host
      Net::SSH.start(host, Setting.remote.user, :password => Setting.remote.password) do |ssh|
        command = "cd %s && git reset --hard HEAD && git pull origin master" % remote_root_path
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

        command = "echo 'source /usr/local/rvm/environments/ruby-1.9.2-p320' >> ~/.bash_profile"
        execute!(ssh, command)

        command = "cd %s && /bin/sh unicorn.sh stop" % remote_root_path
        execute!(ssh, command)

        command = "cd %s && /bin/sh chkdog.sh" % remote_root_path
        execute!(ssh, command)

        command = "cd %s && RACK_ENV=production bundle exec rake agent:deploy" % remote_root_path
        execute!(ssh, command)
        command = "cd %s && RACK_ENV=production bundle exec rake agent:check" % remote_root_path
        execute!(ssh, command)
        command = "cd %s && bundle exec rake crontab:remove" % remote_root_path
        execute!(ssh, command)
        command = "cd %s && bundle exec rake crontab:add" % remote_root_path
        execute!(ssh, command)
        #command = "cd %s && /bin/sh logarc.sh >> log/logarc.log 2>&1" % remote_root_path
        #execute!(ssh, command)
      end
    end
  end
end
