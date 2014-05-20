#encoding: utf-8
require "json"
class ApplicationController < Sinatra::Base
  register Sinatra::Reloader
  register Sinatra::Flash

  helpers ApplicationHelper
  helpers OpenHelper
  helpers Sinatra::FormHelpers
  
  enable :sessions, :logging, :dump_errors, :raise_errors, :static, :method_override

  # css/js/view配置文档
  use SassHandler
  use CoffeeHandler
  use AssetHandler

  #load css/js/font file
  get "/js/:file" do
    disposition_file("javascripts")
  end
  get "/css/:file" do
    disposition_file("stylesheets")
  end

  def disposition_file(file_type)
    file = File.join(ENV["APP_ROOT_PATH"],"app/assets/#{file_type}/#{params[:file]}")
    send_file(file, :disposition => :inline) if File.exist?(file)
  end

  def remote_ip
    request.env["REMOTE_ADDR"] || "n-i-l"
  end

  def remote_browser
    request.env["HTTP_USER_AGENT"] || "n-i-l"
  end
end
