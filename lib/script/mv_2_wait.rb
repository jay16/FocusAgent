#encoding: utf-8
require 'fileutils'
require 'yaml'

# wget => wait
#    \   /
#    spped
WGET_PATH = File.expand_path("../../../public/wget", __FILE__)
LOG_PATH  = File.expand_path("../../../log", __FILE__)
TMP_PATH  = File.expand_path("../../../tmp", __FILE__)

yaml_path = File.expand_path("../../../config/settings.yaml", __FILE__)
raise "yaml file #{yaml_path} not found!" if !File.exist?(yaml_path)

config = YAML.load_file(yaml_path)
mv_speed  = config["development"]["mailgates"]["mv_speed"].to_i
wait_path = config["development"]["mailgates"]["wait_path"]
[WGET_PATH, LOG_PATH, TMP_PATH, wait_path].each do |path|
  raise "file - #{path} not found!" if !File.exist?(path)
end

# store pid when startup process 
pid_file = File.join(TMP_PATH, 'mv_2_wait.pid')
`echo #{Process.pid} > #{pid_file}`
# rm pid file when stop process
trap("INT") { `rm #{pid_file}`; exit }

while (emails=Dir.entries(WGET_PATH).grep(/.eml/)).respond_to?(:each)
  log_path  = File.join(LOG_PATH, Time.now.strftime('%Y%m%d'))
  FileUtils.mkdir_p(log_path) if !File.exist?(log_path)

# log file archive by date
  emails.each do |email|
    puts email

     log = [Time.now.strftime('%Y-%m-%d %H:%M:%S'), Process.pid, email].join(", ")
     `echo #{log} >> #{File.join(log_path,'mv_2_wait.log')}`

    sleep(60 * 60 / mv_speed)
  end if !emails.empty?
end
