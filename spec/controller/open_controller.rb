#encoding: utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "OpenController" do
  def flash; request.env["rack.session"]["flash"]; end
  def options; request.env["rack.session.options"]; end

  it "should receive state [deliver..] when send mail trigger" do
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
    post "/open/mailer", param 

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
end

