namespace :agent do
  def download_file_from_server(wait, url, tarname, md5)
    shell = "cd %s && wget %s" % [wait, url]
    execute!(shell)
   
    path = "%s/%s" % [wait, tarname]
    unless File.exist?(path)
      raise "%s NOT EXIST!" % tarname
    end
    shell = "cd %s && md5 -r %s" % [wait, tarname]
    ret = execute!(shell)
    md5_res = ret[1].split(" ")[0].chomp
    if md5_res == md5 
      shell = "cd %s && tar -xzvf %s" % [wait, tarname]
      execute!(shell)
      return true
    else
      puts "MD5 Can't Match!"
      return false
    end
  end
  task :download => :simple do
    wait = [ENV["APP_ROOT_PATH"], Setting.pool.wait].join
    base_url = "http://%s%s" % [Setting.server.ip, Setting.server.download_path]
    Dir.glob("%s/*.wget" % wait) do |file|
      timestamp, type, tarname, md5, email, strftime, ip = IO.read(file).strip.split(/,/) 
      url = "%s/%s" % [base_url, tarname]
      download_file_from_server(wait, url, tarname, md5)
    end
  end
end
