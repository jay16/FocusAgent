#encoding: utf-8
require "fileutils"

email    = ARGV[0].chomp
tar_name = ARGV[1].chomp
md5      = ARGV[2].chomp
strftime = ARGV[3].chomp

WGET_PATH = File.expand_path("../../../public/wget", __FILE__)
LOG_PATH  = File.expand_path("../../../log/#{Time.now.strftime('%Y%m%d')}", __FILE__)
SERVER    = "main.intfocus.com"

# log file archive by date
FileUtils.mkdir_p(LOG_PATH) unless File.exist?(LOG_PATH)

# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

download_url = "http://#{SERVER}/openapi/#{tar_name}"
puts "email download url: #{download_url}"

# download email from server with linux shell command#wget
run_command( "cd #{WGET_PATH} && wget #{download_url}" )

# deal with the email archive file after download
tar_path = File.join(WGET_PATH,tar_name)
if File.exist?(tar_path) 
   # chk md5 value with the download archive file 
   status, *ret = run_command( "cd #{WGET_PATH} && md5 -r #{tar_name}" )
   if status and  md5 == ret[0].split(" ")[0].chomp
     log = [Time.now.strftime('%Y-%m-%d %H:%M:%S'), email, tar_name, md5, download_url].join(", ")
     `echo #{log} >> #{File.join(LOG_PATH,'wget.log')}`
     # extract email file from archived file when md5 correct
     # mv tar fiel to ../bak after extract
     run_command( "cd #{WGET_PATH} && tar -xzvf #{tar_name} && mv #{tar_name} ../bak" )
   end
end
