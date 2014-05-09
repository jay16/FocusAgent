desc "tasks around CoffeeScript"
namespace :coffee2js do
  desc "CoffeeScript Complie file to JS file"
  task :complie => :environment do
     javascript_path = File.join(ENV["APP_ROOT_PATH"],"app/assets/javascripts")
     coffeescript_path = File.join(ENV["APP_ROOT_PATH"],"app/assets/coffeescripts")
     coffeescripts = Dir.entries(coffeescript_path).find_all { |cs| cs if cs =~ /.*?\.coffee$/ }
     coffeescripts.each do |coffeescript_file|
       begin
         file = File.open(File.join(javascript_path, File.basename(coffeescript_file, ".coffee") + ".js"), "w+")
         file.puts CoffeeScript.compile(File.read(File.join(coffeescript_path,coffeescript_file)))
         file.close
       rescue => e
         puts e.backtrace
       end
       puts "#{coffeescript_file} => complie over."
     end if !coffeescripts.empty?
     puts "complie over."
  end
end
