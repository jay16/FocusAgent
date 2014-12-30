#encoding: utf-8
require "json"
require 'digest/md5'
require "sinatra/multi_route"
class ApplicationController < Sinatra::Base
  # css/js/view配置文档
  use AssetHandler
  use ImageHandler
  use SassHandler
  use CoffeeHandler

  helpers ApplicationHelper
  helpers HomeHelper
  helpers Sinatra::FormHelpers
  
  register Sinatra::Reloader if development? or test?
  register Sinatra::MultiRoute
  register Sinatra::Flash

  before do
    @request_body = request_body
    request_hash = JSON.parse(@request_body) rescue {}
    @params = params.merge(request_hash)
    @params = @params.merge({ip: remote_ip, browser: remote_browser})

    print_format_logger
  end

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
  def run_command(shell, whether_show_log=true, whether_reject_empty=true)
    _result = IO.popen(shell) do |stdout| 
        stdout.readlines#.reject(&method) 
    end.unshift($?.exitstatus.zero?)
    if !_result[0] or whether_show_log
      _shell  = shell.gsub(ENV["APP_ROOT_PATH"], "=>").split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      _status = _result[0]
      _res    = _result.length > 1 ? _result[1..-1].map { |line| "\t\t" + line }.join  : "\t\tbash: no output."
      puts "%s\n\t\t==> %s\n%s\n" % [_shell, _status, _res]
    end
    return _result
  end 

  def print_format_logger
    request_info = @request_body ? %Q{Request:\n #{@request_body }} : ""
    log_info = %Q{
#{request.request_method} #{request.path} for #{request.ip} at #{Time.now.to_s}
Parameters:\n #{@params.to_s}
#{request_info}
    }
    puts log_info
    logger.info log_info
  end

  def request_body(body = request.body)
    case body
    when StringIO then body.string
    when Tempfile then body.read
    # gem#passenger is ugly!
    #     it will change the structure of REQUEST
    #     detail at: https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/utils/tee_input.rb
    when (defined?(PhusionPassenger) and PhusionPassenger::Utils::TeeInput)
      body.read
    # gem#unicorn
    #     it also change the strtucture of REQUEST
    when (defined?(Unicorn) and Unicorn::TeeInput)
      body.read
    when Rack::Lint::InputWrapper
      body.read
    else
      body.to_str
    end
  end

  def respond_with_json hash, code = nil
    hash.perfect!
    raise "code is necessary!" unless hash.has_key?(:code)
    content_type "application/json"
    body   hash.to_json
    status code || 200
  end

  def md5_key(str)
    Digest::MD5.hexdigest(str)
  end

  def login?
    request.cookies["token"] == md5_key(Setting.open.token)
  end

  #alias_method :respond_to_api, :respond_with_json

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
