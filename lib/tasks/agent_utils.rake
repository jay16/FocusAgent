#encoding: utf-8
namespace :agent do
  desc "task - check @options' key"
  task :check => :simple do
    keys = [:pool_wait_path, :pool_download_path, :pool_emails_path, :pool_archived_path, :pool_archived_path,
      :server_path_download, :server_path_mailtest,
      :mg_wait_path, :mg_log_path, :mg_archived_path,
      :app_root_path, :timestamp]
    missings = keys.find_all { |key| not @options.has_key?(key) }
    if missings.empty?
      puts "check result is successfully."
    else
      missings.each do |key|
        "[dangerous] @options missing key - %s" % key
      end
    end
  end

  desc "task - clear tmp files"
  task :clear => :simple do
    @options.keys.find_all { |key| key.to_s =~ /^pool_(.*?)_path$/ }
      .each do |key|
      shell = "rm -rf %s/*" % @options[key]
      execute!(shell)
    end
    puts execute!("tree %s" % base_on_root_path("public"))
  end

  desc "task - mkdir necessary directory paths"
  task :deploy => :simple do
    public_path = base_on_root_path("public")
    ["%s %s/{archived,mailgates,mailtem,openapi,pool}",
     "%s %s/mailtem/mailtest",
     "%s %s/pool/{data,download,emails,wait,archived}",
     "%s %s/mailgates/mqueue/{log,wait}",
     "%s %s/../log"]
    .each do |shell|
      execute!(shell % ["mkdir -p", public_path])
    end
    puts execute!("tree %s" % public_path)
  end

  def download_email_from_server(options)
    download_url       = options[:download_url]
    tar_file_name      = options[:tar_file_name]
    md5_value          = options[:md5_value]
    pool_download_path = options[:pool_download_path]
    pool_emails_path   = options[:pool_emails_path]
    command_md5        = options[:command_md5]
    shell = "cd %s && wget %s" % [pool_download_path, download_url]
    execute!(shell)
   
    file_path = "%s/%s" % [pool_download_path, tar_file_name]
    unless File.exist?(file_path)
      puts "[failure] file not exist - %s" % tar_file_name 
      return false
    end
    shell = "cd %s && %s %s" % [pool_download_path, command_md5, tar_file_name]
    ret = execute!(shell)
    if ret[1].split(" ")[0].chomp != md5_value 
      puts "[failure] md5 not match!"
      return false
    end

    # extract email tar file to /mailgates/mqueue/wait
    shell = "cd %s && tar -xzvf %s -C %s" % [pool_download_path, tar_file_name, pool_emails_path]
    execute!(shell)
    return true
  end

  def move_email_to_mailgates_wait(email_file_path, options)
    mg_wait_path = options[:mg_wait_path]

    unless File.exist?(email_file_path)
      puts "[failure] file not exist - %s" % email_file_path
      return false
    end
    unless File.exist?(mg_wait_path)
      puts "[failure] directory not exist - %s" % mg_wait_path
      return false
    end
    FileUtils.mv(email_file_path, mg_wait_path)
    return true
  end
  def download_mailtest_files_from_server(pool_download_path, pool_emails_path, server_ip, file_name, md5)
    download_url = "http://%s/mailtem/mailtest/%s" % [server_ip, file_name]
    shell = "cd %s && wget %s" % [pool_download_path, download_url]
    execute!(shell)
   
    file_path = File.join(pool_download_path,file_name)
    unless File.exist?(file_path)
      puts "[failure] file not exist - %s" % file_path
      return false
    end

    shell = "cd %s && md5sum %s" % [pool_download_path, file_name]
    ret = execute!(shell)
    md5_res = ret[0].split(" ")[0].chomp
    if md5_res != md5
      puts "[failure] md5 not match:\nexpected: %s\nget: %s" % [md5, md5_res]
      return false
    end

    shell = "cd %s && tar -xzvf %s -C %s" % [pool_download_path, file_name, pool_emails_path]
    execute!(tar_str)
  end
   
  def move_mailtest_emails_to_mailgates_wait (directory_path, dest_path)
    domains = []
    Dir.glob(direcotry_path) do |dir_path|
      dir_name = File.basename(dir_pat)
      next if %w[. ..].include?(dir_name)
      next unless File.directory?(dir_path)

      domains.push({:domain => dir, :path => dir_path}) 
    end
    domains.uniq.each do |hash|
      puts "[mailtest] domain: #{hash[:domain]}"
      Dir.glob(hash[:path] + "/.eml") do |email|
        file_path = File.join(hash[:path], email)
        FileUtils.mv(file_path,@wait_path)
      end
    end
  end

  def write_action_logger(log_type, options)
    logger_path = File.join(options[:pool_data_path], log_type + ".csv")
    timestamp   = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    log_content = [timestamp, File.basename(options[:tar_file_name] || options[:email_file_path])].join(",")
    shell = %Q{echo "%s" >> %s} % [log_content, logger_path]
    execute!(shell)
  end
end
