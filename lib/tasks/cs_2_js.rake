#encoding:utf-8
desc "tasks around CoffeeScript"
namespace :cs2js do

  def lasttime_for_compile(info, klass, &block)
     bint = Time.now.to_f
     yield
     eint = Time.now.to_f
     printf("%-20s - %s Complie over.[%sms]\n", file, klass, ((eint - bint)*1000).to_i)
  end

  def compile(source, target, regexp, klass, sbasename, tbasename)
     assets_path = File.join(ENV["APP_ROOT_PATH"],"app/assets")
     source_path = "%s/%s" % [assets_path, source]
     target_path = "%s/%s" % [assets_path, target]
     files = Dir.entries(source_path).select { |file| file =~ regexp }

     files.each do |file|
       lasttime_for_compile file, klass.name do
         begin
           File.open(File.join(target_path, File.basename(file, sbasename) + tbasename), "w:utf-8") do |f|
             f.puts klass.compile(File.read(File.join(source_path,file)))
           end
         rescue => e
           puts e.backtrace
         end
       end
     end if !files.empty?
  end
  desc "CoffeeScript Complie file to JS file"
  task :compile => :environment do
    compile("coffeescripts", "javascripts", /.*?\.coffee$/, CoffeeScript, ".coffee", ".js")
    #compile("sass", "stylesheets", /.*?\.scss$/, Sass, ".scss", ".css")
  end
end
