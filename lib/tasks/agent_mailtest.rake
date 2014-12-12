#encoding: utf-8
namespace :agent do
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
end
