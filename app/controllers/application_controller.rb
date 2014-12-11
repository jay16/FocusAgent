#encoding: utf-8
require "json"
class ApplicationController < Sinatra::Base
  # css/js/view配置文档
  use AssetHandler
  use ImageHandler
  use SassHandler
  use CoffeeHandler

  helpers ApplicationHelper
  helpers HomeHelper
  helpers Sinatra::FormHelpers
  
  register Sinatra::Reloader if development?
  register Sinatra::MultiRoute
  register Sinatra::Flash

  before do
    print_format_logger
  end

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

  # execute linux shell command
  # return array with command result
  # [execute status, execute result] 
  def run_command(cmd)
    IO.popen(cmd) do |stdout|
      stdout.reject(&:empty?)
    end.unshift($?.exitstatus.zero?)
  end 

  def print_format_logger
    hash = params || {}
    info = {:ip => remote_ip, :browser => remote_browser}
    params = hash.merge(info)
    log_info = %Q{
#{request.request_method} #{request.path} for #{request.ip} at #{Time.now.to_s}
Parameters:\n #{params.to_s}
Request:\n #{request_body if request.body}
    }
    puts log_info
    logger.info log_info
  end

  def request_body(body = request.body)
    @request_body = case body
    when StringIO then body.string
    when Tempfile then body.read
    # gem#passenger is ugly!
    #     it will change the structure of REQUEST
    #     detail at: https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/utils/tee_input.rb
    when (defined?(PhusionPassenger) and PhusionPassenger::Utils::TeeInput)
      body.read
    # gem#unicorn
    #     it also change the strtucture of REQUEST
    when Rack::Lint::InputWrapper
      body.read
    else
      body.to_str
    end
  end

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
