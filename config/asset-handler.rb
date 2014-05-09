require "fileutils"
require "logger"

class SassHandler < Sinatra::Base
    set :views, ENV["APP_ROOT_PATH"] +  "/app/assets/stylesheets"
    
    get '/stylesheets/*.scss' do
        filename = params[:splat].first
        scss filename.to_sym
    end
end
 
class CoffeeHandler < Sinatra::Base
    set :views, ENV["APP_ROOT_PATH"] +  "/app/assets/javascripts"
    
    get "/javascripts/*.coffee" do
        filename = params[:splat].first
        coffee filename.to_sym
    end
end


class AssetHandler < Sinatra::Base

  configure do
    enable :logging, :static, :sessions 
    enable :dump_errors, :raise_errors, :show_exceptions
    enable :method_override
    enable :coffeescript

    Logger.class_eval { alias :write :'<<' }
    logger_file = File.join(ENV["APP_ROOT_PATH"], "log/#{ENV['RACK_ENV']}.log")
    logger = ::Logger.new(::File.new(logger_file, "a+"))
    use Rack::CommonLogger, logger


    set :root,  ENV["APP_ROOT_PATH"]
    set :views, ENV["VIEW_PATH"]
    set :public_folder, ENV["APP_ROOT_PATH"] + "/app/assets"
    set :js_dir,  ENV["APP_ROOT_PATH"] +  "/app/assets/javascripts"
    set :css_dir, ENV["APP_ROOT_PATH"] + "/app/assets/stylesheets"

    #set :erb, :layout_engine => :erb, :layout => :layout
    set :haml, :layout_engine => :haml, :layout => :"/app/views/layouts/layout"
    set :cssengine, "css"
  end

   # 加载数据库及model
   # db_path = File.join(ENV["APP_ROOT_PATH"], "db")
   # FileUtils.mkdir_p(db_path) unless File.exist?(db_path)
   require "database"

end
