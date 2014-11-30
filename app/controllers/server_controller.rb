#encoding: utf-8
# mock focus_mail server 
class ServerController < ApplicationController

  # 1. get /server will generate a email file and tar
  # 2. send notifiction to agent 
  get "/" do
    base_path  = "%s/public/openapi" % ENV["APP_ROOT_PATH"]
    email      = Time.now.to_f.to_s + ".eml"
    tar_name   = email + ".tar.gz"
    File.open("%s/%s" % [base_path, email], "w:utf-8") do |file|
      file.puts "hello world - %s" % Time.now.to_s
    end
    shell = "cd %s && tar -czvf %s %s && md5 -r %s" % [base_path, tar_name, email, tar_name]
    result = run_command(shell)
    md5_value = result[1].split[0].strip

    param = {
      :email    => email,
      :tar_name => tar_name,
      :md5      => md5_value,
      :strftime => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    param.to_s
    agent_url = "http://%s/open/mailer" % Setting.server.agent_ip
    puts agent_url
    resource = self.call(
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => '/server/hello',
    'rack.input' => StringIO.new
    )[2].join('')
    #res = RestClient.post agent_url, param.to_json, :content_type => :json, :accept => :json
    resource
  end

  get "/hello" do
    "hello world"
  end
  # 3. get /server/openapi will download tarfile 
  get "/openapi" do
  end
end
