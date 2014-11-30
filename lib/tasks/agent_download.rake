namespace :agent do
  def download_file_from_server(wait, url, tar_name)
    shell = "cd %s && wget %s" % [wait, url]
    run_command(shell)
   
    tar_path = "%s/%s" % [wait, tar_name]
    unless File.exist?(tar_path)
       puts "Wget Fail!"
       return false
    end
    shell = "cd %s && md5sum %s" % [wait, tar_name]
    ret = run_command(shell)
    md5_res = ret[0].split(" ")[0].chomp
    if md5_res == md5 
      shell = "cd %s && tar -xzvf %s" % [wait, tar_name]
      run_command(shell)
      return true
    else
      puts "MD5 Can't Match!"
      return false
    end
  end
  task "download" => :environment do
    wait = "%s/%s" % [ENV["APP_ROOT_PATH"], Setting.pool.wait]
    url = "http://%s%s/%s" % [Setting.server.ip, Setting.server.download_path, tar_name]

  end
end
