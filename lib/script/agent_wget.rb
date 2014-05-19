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
    download_url = "http://#{SERVER}/openapi/#{filename}"

    # download email from server with linux shell command#wget
    status, *result = run_command( "cd #{WGET_FILE} && wget #{download_url}" )
    next if !status

    # deal with the email archive file after download
    tar_path = File.join(WGET_FILE,filename)

    # chk md5 value with the download archive file 
    status, *ret = run_command( "cd #{WGET_FILE} && md5 -r #{filename}" )
    if status and  md5 == ret[0].split(" ")[0].chomp
      log = [Time.now.strftime('%Y-%m-%d %H:%M:%S'), type, filename, md5, download_url].join(", ")
      `echo #{log} >> #{File.join(LOG_PATH,'agent_wget.log')}`
      # extract email file from archived file when md5 correct
      # mv tar fiel to ../bak after extract
      run_command( "cd #{WGET_FILE} && tar -xzvf #{filename} && mv #{filename} #{WGET_BAK}" )
      run_command( "cd #{WGET_POOL} && mv #{file} #{WGET_BAK}" )
    else
      File.delete(tar_path) if File.exist?(tar_path)
    end
  end 
end
