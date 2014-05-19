#encoding: utf-8
require 'fileutils'
require 'yaml'

# wget => wait
#    \   /
#    spped
# /public/wget: email file
# /log : mv email file to mailgates/wait log
# /tmp : mv2wait.pid
# /wget_pool: wget email tar.gz file from server
# /wget_file: extract email file from tar.gz
# /wget_bak:  bak tar file here when extract tar.gz file
WGET_FILE = File.expand_path("../../../public/wget_file", __FILE__)
LOG_PATH  = File.expand_path("../../../log", __FILE__)
TMP_PATH  = File.expand_path("../../../tmp", __FILE__)

# mv_speed: speed of move email file to /mailgates/wait
# wait_path: mailgates/wait path
mv_speed  = ARGV[0].to_i
wait_path = ARGV[1]
[WGET_FILE, LOG_PATH, TMP_PATH, wait_path].each do |path|
  raise "file - #{path} not found!" if !File.exist?(path)
end

# store pid when startup process 
pid_file = File.join(TMP_PATH, 'agent_mv2wait.pid')
pid = Process.pid
`echo #{pid} > #{pid_file}`
# rm pid file when stop process
trap("INT") { `rm #{pid_file}`; exit }

while (emails=Dir.entries(WGET_FILE).grep(/.eml$/)).respond_to?(:each)
  emails.empty? ? sleep(1) : emails.each do |email|
    email_path = File.join(WGET_FILE, email)
    `mv #{email_path} #{wait_path}`

    log = [Time.now.strftime('%Y-%m-%d %H:%M:%S'), pid, mv_speed, email].join(", ")
    `echo #{log} >> #{File.join(LOG_PATH,'mv_2_wait.log')}`

    sleep(60 * 60 / mv_speed)
  end
end
