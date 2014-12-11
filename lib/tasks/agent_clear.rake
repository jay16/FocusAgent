#encoding: utf-8
namespace :agent do
  task :clear => :simple do
    app_root_path = ENV["APP_ROOT_PATH"]
    [ File.join(app_root_path, Setting.pool.wait),
      File.join(app_root_path, Setting.pool.download),
      File.join(app_root_path, Setting.pool.emails),
      File.join(app_root_path, "public", Setting.server.download_path),
      File.join(app_root_path, Setting.mailgates.path.wait)
    ].each do |path|
      shell = "rm -f %s/*" % path
      puts shell
      puts execute!(shell)
    end
    puts execute!("tree %s" % File.join(app_root_path, "public"))
  end
end
