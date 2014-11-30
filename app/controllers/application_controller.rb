#encoding: utf-8
require "json"
class ApplicationController < Sinatra::Base
  register Sinatra::Reloader
  #register Sinatra::Flash

  helpers ApplicationHelper
  helpers HomeHelper
  helpers Sinatra::FormHelpers
  
  enable :sessions, :logging, :dump_errors, :raise_errors, :static, :method_override

  # css/js/view配置文档
  use ImageHandler
  use SassHandler
  use CoffeeHandler
  use AssetHandler

  #load css/js/font file
  #get "/js/:file" do
  #  disposition_file("javascripts")
  #end
  #get "/css/:file" do
  #  disposition_file("stylesheets")
  #end

  #def disposition_file(file_type)
  #  file = File.join(ENV["APP_ROOT_PATH"],"app/assets/#{file_type}/#{params[:file]}")
  #  send_file(file, :disposition => :inline) if File.exist?(file)
  #end

  def remote_ip
    request.ip 
  end
  def remote_path
    request.path 
  end
  def remote_browser
    request.user_agent
  end
  def run_shell(cmd)
    IO.popen(cmd) do |stdout| 
      stdout.reject(&:empty?) 
    end.unshift($?.exitstatus.zero?)
  end 

  #[:erb, :haml, :slim].each do |method_name|
  #  define_method "#{method_name}_with_layout" do |template, options|
  #    unless options.include?(:layout)
  #      begin
  #      options[:layout] = settings.layout 
  #      rescue  => e
  #        puts e.message
  #      end
  #    end
  #    send(method_name, template, options)
  #  end

  #  alias_method_chain method_name, :layout
  #end

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
