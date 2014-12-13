#encoding: utf-8
require "fileutils"
namespace :agent do
  task :main => :simple do
    base_url = "http://%s%s" % [@options[:server_ip], @options[:server_path_download]]
    Dir.entries(@options[:pool_wait_path]).each do |file|
      next unless file =~ /^api-(.*?).csv$/

      file_path = File.join(@options[:pool_wait_path], file)
      timestamp, type, tarname, md5, email, strftime, ip = IO.read(file_path).strip.split(/,/) 
      options = {
        :download_url => "%s/%s" % [base_url, tarname],
        :md5_value    => md5,
        :tar_file_name => tarname,
      }
      download_email_from_server(@options.merge(options))
    end
    Dir.glob("%s/*.eml" % @options[:pool_emails_path]) do |email_file_path|
      move_email_to_mailgates_wait(email_file_path, @options)
    end
  end
end
