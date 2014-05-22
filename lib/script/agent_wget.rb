#encoding: utf-8
require "fileutils"

# api => wget_pool/wget_info.wget
# read wget_pool/wget_info.wget => linux shell [wget] => wget_file/wget_file.tar.gz
# tar -xzvf wget_file.tar.gz => wget_file/wget_file.eml; wget_file.tar.gz => wget_bak/
# last remove wget_pool/wget_info.wget
#
# the file pool wait for wgets
# filename like xxx.wget
WGET_POOL = File.expand_path("../../../public/wget_pool", __FILE__)
WGET_FILE = File.expand_path("../../../public/wget_file", __FILE__)
WGET_BAK  = File.expand_path("../../../public/wget_bak", __FILE__)
LOG_PATH  = File.expand_path("../../../log/", __FILE__)
TMP_PATH  = File.expand_path("../../../tmp", __FILE__)
SERVER    = "main.intfocus.com"

[WGET_POOL, WGET_FILE, WGET_BAK, TMP_PATH, LOG_PATH].each do |path|
  raise "file - #{path} not found!" if !File.exist?(path)
end

# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

# store pid when startup process 
pid_file = File.join(TMP_PATH, 'agent_wget.pid')
pid = Process.pid
`echo #{pid} > #{pid_file}`
# rm pid file when stop process
trap("INT") { `rm #{pid_file}`; exit }

while (files = Dir.entries(WGET_POOL).grep(/.wget/)).respond_to?(:each)
  files.empty? ? sleep(1) : files.each do |file|
    file_path = File.join(WGET_POOL, file)
    lines = IO.readlines(file_path)
    timestamp, type, filename, md5, *other = lines[0].split(",")

    # different url with different api type
    url_path = (type.to_s.downcase.strip == "api" ?  "openapi" : "mailtem/mailtest")
    download_url = "http://#{SERVER}/#{url_path}/#{filename}"

    # download email from server with linux shell command#wget
    status, *result = run_command( "cd #{WGET_FILE} && wget #{download_url}" )
    next if !status

    # deal with the email archive file after download
    tar_path = File.join(WGET_FILE,filename)

    # chk md5 value with the download archive file 
    status, *ret = run_command( "cd #{WGET_FILE} && md5sum #{filename}" )
    if status and  md5 == ret[0].split(" ")[0].chomp
      log = [Time.now.strftime('%Y-%m-%d %H:%M:%S'), type, filename, md5, download_url].join(", ")
      `echo #{log} >> #{File.join(LOG_PATH,'agent_wget.log')}`

      # extract email file from archived file when md5 correct
      # mv tar.gz and .wget file to ../bak after extract
      run_command( "cd #{WGET_FILE} && tar -xzvf #{filename} && mv #{filename} #{WGET_BAK}" )
      run_command( "cd #{WGET_POOL} && mv #{file} #{WGET_BAK}" )

      # 322_MailTest_20140414231032/qq/561274_1397488232.187485.eml
      if type.to_s.downcase.strip == "test"
        test_dir_name = File.basename(filename, ".tar.gz")
        test_dir_path = File.join(WGET_FILE, test_dir_name)
        Dir.entries(test_dir_path) do |domain|
          next if domain == "." or domain == ".."
          test_domain_path = File.join(test_dir_path, domain)
          Dir.entries(test_domain_path).grep(/.eml$/) do |email|
            test_email_path = File.join(test_domain_path, email)
            new_email_name = [test_dir_name, domain, email].join("_")
            new_email_path = File.join(WGET_FILE, new_email_name)
            `mv #{test_email_path} #{new_email_path} && rm -fr #{test_dir_path}`
          end
        end
      end

    else
      File.delete(tar_path) if File.exist?(tar_path)
    end
  end 
end
