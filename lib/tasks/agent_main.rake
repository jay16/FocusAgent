#encoding: utf-8
require "fileutils"
namespace :agent do
  def download_file_from_server(pool_download_path, pool_emails_path, download_url, tarname, md5)
    shell = "cd %s && wget %s" % [pool_download_path, download_url]
    execute!(shell)
   
    file_path = "%s/%s" % [pool_download_path, tarname]
    unless File.exist?(file_path)
      puts "[failure] file not exist - %s" % tarname 
      return false
    end
    shell = "cd %s && md5 -r %s" % [pool_download_path, tarname]
    ret = execute!(shell)
    md5_res = ret[1].split(" ")[0].chomp
    if md5_res != md5 
      puts "[failure] md5 can't match!"
      return false
    end
    shell = "cd %s && tar -xzvf %s -C %s" % [pool_download_path, tarname, pool_download_path]
    execute!(shell)
    return true
  end

  def move_email_to_mailgates_wait(email_file_path, mailgates_wait_path)
    unless File.exist?(email_file_path)
      puts "[failure] file not exist - %s" % email_file_path
      return false
    end
    unless File.exist?(mailgates_wait_path)
      puts "[failure] directory not exist - %s" % mailgates_wait_path
      return false
    end
    FileUtils.mv(email_file_path, mailgates_wait_path)
    return true
  end

  task :main => :simple do
    app_root_path = ENV["APP_ROOT_PATH"]
    pool_wait_path      = File.join(app_root_path, Setting.pool.wait)
    pool_download_path  = File.join(app_root_path, Setting.pool.download)
    pool_emails_path    = File.join(app_root_path, Setting.pool.emails)
    mailgates_wait_path = File.join(app_root_path, Setting.mailgates.path.wait)
    base_url = "http://%s%s" % [Setting.server.ip, Setting.server.path.download]
    puts pool_wait_path
    Dir.entries(pool_wait_path).each do |file|
      puts file
      next unless file =~ /^api-.*.wget$/

      file_path = File.join(pool_wait_path, file)
      timestamp, type, tarname, md5, email, strftime, ip = IO.read(file_path).strip.split(/,/) 
      download_url = "%s/%s" % [base_url, tarname]
      download_file_from_server(pool_download_path, pool_emails_path, download_url, tarname, md5)
    end
    Dir.glob("%s/*.eml" % pool_emails_path) do |email_file_path|
      move_email_to_mailgates_wait(email_file_path, mailgates_wait_path)
    end
  end
end
