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
      puts "@options' keys  all ok."
    else
      missings.each do |key|
        puts "[dangerous] @options missing key - %s" % key
      end
    end
    not_exists = keys.find_all { |key| key =~ /_path$/ and not File.exist?(@options[key]) }
    if not_exists.empty?
      puts "@options' paths all ok."
    else
      not_exists.each do |key|
        puts "[dangerous] file not eixst - @options[%s] = %s" % [key, @options[key]]
      end
    end

    # check basic tmp directory
    not_exists = %w[log tmp tmp/pids].find_all do |dir|
      not File.exist?(File.join(@options[:app_root_path], dir))
    end
    if not_exists.empty?
      puts "basic tmp dir all ok."
    else
      not_exists.each do |dir|
        puts "[warn] tmp direcoty not exist - %s" % dir
      end
    end

    # tmp config files
    app_root_path = File.read(File.join(@options[:app_root_path], "tmp/app_root_path")).strip rescue "not exist"
    puts "tmp/app_root_path is %s." % (app_root_path == @options[:app_root_path] ? "ok" : "incorrect")
    pool_wait_path = File.read(File.join(@options[:app_root_path], "tmp/pool_wait_path")).strip rescue "not exist"
    puts "tmp/pool_wait_path is %s." % (pool_wait_path == @options[:pool_wait_path] ? "ok" : "incorrect")
  end

  desc "task - clear tmp files"
  task :clear => :simple do
    @options.keys.find_all { |key| key.to_s =~ /^pool_(.*?)_path$/ }
      .each do |key|
      shell = "rm -rf %s/*" % @options[key]
      execute!(shell)
    end
    execute!("tree %s" % base_on_root_path("public"))
  end

  desc "task - mkdir necessary directory paths"
  task :deploy => :simple do
    @options.keys
      .find_all { |key| key =~ /^pool_(.*?)_path$/ }
      .map { |key| @options[key] }
      .each { |path| execute!("mkdir -p %s" % path) }

    execute!("mkdir -p %s" % base_on_root_path("log"))

    if ENV["RACK_ENV"] == "test"
      @options.keys
        .find_all { |key| key =~ /^mg_(.*?)_path$/ }
        .map { |key| @options[key] }
        .each { |path| execute!("mkdir -p %s" % path) }

      @options.keys
        .find_all { |key| key =~ /^server_path/ }
        .map { |key| base_on_root_path(File.join("public", @options[key])) }
        .each { |path| execute!("mkdir -p %s" % path) }
    end

    %w[log tmp tmp/pids].find_all do |dir|
      tmp_dir = File.join(@options[:app_root_path], dir)
      execute!("test -d %s || mkdir -p %s" % [tmp_dir, tmp_dir])
    end
    execute!("echo %s > %s/tmp/app_root_path" % [@options[:app_root_path], @options[:app_root_path]])
    execute!("echo %s > %s/tmp/pool_wait_path" % [@options[:pool_wait_path], @options[:app_root_path]])
    puts execute!("tree %s" % base_on_root_path("public"))
  end

  def download_email_from_server(options)
    download_url       = options[:download_url]
    tar_file_name      = options[:tar_file_name]
    md5_value          = options[:md5_value]
    pool_download_path = options[:pool_download_path]
    pool_emails_path   = options[:pool_emails_path]
    command_md5        = options[:command_md5]
    shell = "cd %s && wget --quiet %s" % [pool_download_path, download_url]
    execute!(shell)
   
    file_path = "%s/%s" % [pool_download_path, tar_file_name]
    unless File.exist?(file_path)
      puts_with_space "\t[failure] download tar file not exist - %s" % file_path
      return false
    end

    shell = "cd %s && %s %s" % [pool_download_path, command_md5, tar_file_name]
    ret = execute!(shell)
    md5_res = ret[1].split[0].chomp 
    if md5_res != md5_value 
      puts_with_space "\t[failure] download tar file's md5 not match:\n$!$\texpected: %s\n$!$\tgot: %s" % [md5, md5_res]
      return false
    end
    action_logger("download", tar_file_name)

    # extract email tar file to /mailgates/mqueue/wait
    shell = "cd %s && tar -xzf %s -C %s" % [pool_download_path, tar_file_name, pool_emails_path]
    execute!(shell)
    
    archived_file(File.join(pool_download_path, tar_file_name), options)
    return true
  end

  def move_email_to_mailgates_wait(email_file_path, options)
    mg_wait_path = options[:mg_wait_path]

    unless File.exist?(email_file_path)
      puts_with_space "\t[failure] email file not exist - %s" % email_file_path
      return false
    end
    unless File.exist?(mg_wait_path)
      puts_with_space "\t[failure] mg#wait directory not exist - %s" % mg_wait_path
      return false
    end

    code = FileUtils.mv(email_file_path, mg_wait_path) rescue -1
    if code == -1
      puts_with_space "\t[failure] move email to mg#wait.\n$!$\tsource file: %s\n$!$\ttarget path: %s" % [email_file_path, mg_wait_path]
      return false
    end

    action_logger("move", email_file_path)
    return true
  end

  # sperator line

  def download_mailtest_emails_from_server(options)
    server_ip          = options[:server_ip]
    tar_file_name      = options[:tar_file_name]
    md5_value          = options[:md5_value]
    command_md5        = options[:command_md5]
    pool_download_path = options[:pool_download_path]
    pool_emails_path   = options[:pool_emails_path]

    download_url = "http://%s/mailtem/mailtest/%s" % [server_ip, tar_file_name]
    shell = "cd %s && wget --quiet %s" % [pool_download_path, download_url]
    execute!(shell)
   
    tar_file_path = File.join(pool_download_path, tar_file_name)
    unless File.exist?(tar_file_path)
      puts_with_space "\t[failure] tar file not exist - %s" % tar_file_path
      return false
    end

    shell = "cd %s && %s %s" % [pool_download_path, command_md5, tar_file_name]
    ret = execute!(shell)
    md5_res = ret[1].split[0].chomp 
    if md5_res != md5_value
      puts_with_space "\t[failure] download tar file's md5 not match:\n$!$\texpected: %s\n$!$\tgot: %s" % [md5, md5_res]
      return false
    end
    action_logger("download", tar_file_name)

    shell = "cd %s && tar -xzf %s -C %s" % [pool_download_path, tar_file_name, pool_emails_path]
    execute!(shell)

    archived_file(File.join(pool_download_path, tar_file_name), options)
    return true
  end
   
  def move_mailtest_emails_to_mailgates_wait(mailtest_path, options)
    Dir.glob(mailtest_path + "/*").each do |dir_path|
      next unless File.directory?(dir_path)

      Dir.glob(dir_path + "/*.eml") do |email_file_path|
        FileUtils.mv(email_file_path, options[:mg_wait_path])
        action_logger("move", email_file_path)
      end
    end
    FileUtils.rm_rf(mailtest_path)
    return true
  end

  def action_logger(action_type, file_path="unset", options=@options)
    logger_path = File.join(options[:pool_data_path], options[:timestamp], action_type + ".csv")
    timestamp   = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    log_content = [timestamp, File.basename(file_path || "empty")].join(",")
    shell = %Q{echo "%s" >> %s} % [log_content, logger_path]
    execute!(shell)
  end

  def archived_file(file_path, options)
    archived_path = File.join(options[:pool_archived_path], options[:timestamp])
    FileUtils.mv(file_path, archived_path)
  end

  def archived_bad(file_path, options)
    pool_bad_path = File.join(options[:pool_bad_path], options[:timestamp])

    shell = "test -d %s || mkdir -p %s" % [pool_bad_path, pool_bad_path]
    execute!(shell)

    FileUtils.mv(file_path, pool_bad_path)
  end

  def lasttime(info, &block)
    now  = Time.now
    puts "Started at %s" % now.strftime("%Y-%m-%d %H:%M:%S")
    bint = now.to_f
    yield
    now  = Time.now
    eint = now.to_f
    printf("Completed %s in %s - %s\n\n", now.strftime("%Y-%m-%d %H:%M:%S"), "%dms" % ((eint - bint)*1000).to_i, info)
  end

  def uniq_task(t)  
    $0 = ["rake", t.name].join(":")  
    #raise "This task is running!!" 
    if %x{ps aux|grep #{$0}|awk '{print $11}'}.split("\n").find_all{|x| x==$0 }.size > 1  
      return false
    else
      return true
    end
  end  

  def puts_with_space(text, options=@options)
    gap_space = options[:gap_space]
    text.gsub!("$!$", gap_space)
    puts "%s%s" % [gap_space, text]
  end
end
