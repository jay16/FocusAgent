#encoding: utf-8
namespace :agent do
  task :clear => :simple do
    app_root_path = ENV["APP_ROOT_PATH"]
    [ File.join(app_root_path, Setting.pool.wait),
      File.join(app_root_path, Setting.pool.download),
      File.join(app_root_path, Setting.pool.emails),
      File.join(app_root_path, "public", Setting.server.path.download),
      File.join(app_root_path, "public", Setting.server.path.mailtest),
      File.join(app_root_path, Setting.mailgates.path.wait),
      File.join(app_root_path, Setting.pool.mailtest)
    ].each do |path|
      shell = "rm -rf %s/*" % path
      puts shell
      puts execute!(shell)
    end
    puts execute!("tree %s" % File.join(app_root_path, "public"))
  end

  task :deploy => :simple do
    app_root_path = ENV["APP_ROOT_PATH"]
    shell = "mkdir -p %s/public/{archived,mailgates,mailtem,openapi,pool}" % app_root_path
    execute!(shell)
    shell = "mkdir -p %s/public/pool/{backup,download,emails,wait}" % app_root_path
    execute!(shell)
    shell = "mkdir -p %s/public/mailgates/mqueue/{log,wait}" % app_root_path
    execute!(shell)
    puts execute!("tree %s" % File.join(app_root_path, "public"))
  end
end
