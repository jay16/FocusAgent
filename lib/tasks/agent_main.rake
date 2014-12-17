#encoding: utf-8
require "fileutils"
namespace :agent do
  desc "task - open#api"
  task :open_api do
    base_url = "http://%s%s" % [@options[:server_ip], @options[:server_path_download]]
    Dir.entries(@options[:pool_wait_path]).each do |file|
      next unless file =~ /^api-(.*?).csv$/

      file_path = File.join(@options[:pool_wait_path], file)
      timestamp, type, tar_file_name, md5, email, strftime, ip = IO.read(file_path).strip.split(/,/) 
      options = {
        :download_url => "%s/%s" % [base_url, tar_file_name],
        :md5_value    => md5,
        :tar_file_name => tar_file_name,
      }
      download_email_from_server(@options.merge(options))
      archived_file(file_path, @options)
    end
    Dir.glob("%s/*.eml" % @options[:pool_emails_path]) do |email_file_path|
      move_email_to_mailgates_wait(email_file_path, @options)
    end
  end

  desc "task - campaign#listener.json"
  task :mailtest do
    base_url = "http://%s%s" % [@options[:server_ip], @options[:server_path_mailtest]]
    Dir.entries(@options[:pool_wait_path]).each do |file|
      next unless file =~ /^test-(.*?).csv$/

      file_path = File.join(@options[:pool_wait_path], file)
      timestamp, type, file_name, md5, mail_type, blank, ip = IO.read(file_path).strip.split(/,/) 
      tar_file_name = "%s.tar.gz" % file_name
      options = {
        :download_url  => "%s/%s.tar.gz" % [base_url, tar_file_name],
        :md5_value     => md5,
        :tar_file_name => tar_file_name,
      }
      download_mailtest_emails_from_server(@options.merge(options))
      mailtest_path = File.join(@options[:pool_emails_path], file_name)
      move_mailtest_emails_to_mailgates_wait(mailtest_path, @options)
      archived_file(file_path, @options)
    end
  end
  task :main => :simple do |t|
    lasttime "Rake Task agent:main" do
      if uniq_task(t)  
        puts "\tenvironment:\t" + @options[:rack_env]
        execute!("whoami")
        [@options[:pool_data_path], @options[:pool_archived_path]].each do |path|
          shell = "cd %s && test -d %s || mkdir %s" % [path, @options[:timestamp], @options[:timestamp]]
          execute!(shell, false)
        end

        Rake::Task["agent:open_api"].invoke
        Rake::Task["agent:mailtest"].invoke
      else
        puts "\tLast Task is running."
      end

      crontab_data_file = File.join(@options[:pool_data_path], @options[:timestamp], "crontab.csv")
      shell = %Q{echo "%s" >> %s} % [Time.now.strftime("%Y/%m/%d %H:%M:%S"), crontab_data_file] 
      execute!(shell, false)
    end
  end
end
