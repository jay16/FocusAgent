require "date"
require "yaml"
require "yaml/store"

configure do
  #db_name =[ENV["APP_NAME"], ENV["RACK_ENV"]].join("_")
  #DataMapper::setup(:default, "sqlite3://#{ENV['APP_ROOT_PATH']}/db/#{db_name}.db")

  #加载model文件前把os信息配置ok
  yaml_path = File.join(ENV["APP_ROOT_PATH"], "/config/settings.yaml")
  raise "not found config/settings.yaml" unless File.exist?(yaml_path)

  yaml = YAML::Store.new(yaml_path)
  yaml_load = YAML.load_file(yaml_path)
  puts yaml_load["default"]["title"]
  yaml.transaction do
    yaml["default"]["os"]["issue"] = `cat /etc/issue | head -n 1`.to_s || "/etc/issue"
    yaml["default"]["os"]["hostname"] = `hostname`.to_s || "hostname"
  end

  # 加载所有models
  Dir.glob("#{ENV['APP_ROOT_PATH']}/app/models/*.rb").each { |file| require file }

  ## 自动迁移数据库
  #DataMapper.finalize.auto_upgrade!
  ##DataMapper.finalize.auto_migrate!

  ##启动后保证db文件有被读写权限
  #system("chmod 777 #{ENV['APP_ROOT_PATH']}/db/*")
end

