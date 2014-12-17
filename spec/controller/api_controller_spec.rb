#encoding: utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "APIController" do
  def flash; request.env["rack.session"]["flash"]; end
  def options; request.env["rack.session.options"]; end

  def generate_email_file_and_params
    base_path  = "%s/public/openapi" % ENV["APP_ROOT_PATH"]
    email      = Time.now.to_f.to_s + ".eml"
    tar_name   = email + ".tar.gz"
    File.open("%s/%s" % [base_path, email], "w:utf-8") do |file|
      file.puts "hello world - %s" % Time.now.to_s
    end
    shell = "cd %s && tar -czvf %s %s && md5 -r %s" % [base_path, tar_name, email, tar_name]
    puts shell
    result = run_command(shell)
    puts result.join("\n")
    md5_value = result[1].split[0].strip

    # remove email file
    shell = "cd %s && rm -f %s" % [base_path, email]
    result = run_command(shell)
    return {
      :email    => email,
      :tar_name => tar_name,
      :md5      => md5_value,
      :strftime => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
  end

  def generate_mailtest_files_and_params
    folder_name = [rand(1000).to_s, "MailTest", Time.now.strftime("%Y%m%d%H%M%S")].join("_")
    base_path   = "%s/public/mailtem/mailtest" % ENV["APP_ROOT_PATH"]
    %w[qq sina gmail 163 other].each do |domain|
      domain_path = File.join(base_path, folder_name, domain) 
      shell = "mkdir -p %s" % domain_path
      run_command(shell)

      email = Time.now.to_f.to_s + ".eml"
      File.open("%s/%s" % [domain_path, email], "w:utf-8") do |file|
        file.puts "only test for %s" % domain
      end
    end

    shell = "cd %s && tar -czvf %s.tar.gz %s && md5 -r %s.tar.gz" % [base_path, folder_name, folder_name, folder_name]
    puts shell
    result = run_command(shell)
    puts result
    md5_value = result[1].split[0].strip

    # remove email file
    shell = "cd %s && rm -fr %s" % [base_path, folder_name]
    result = run_command(shell)
    return {
      :filename  => folder_name,
      :mail_type => 0,
      :md5       => md5_value,
      :sdate     => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
  end

  it "should receive [deliver..] when GET open#mailer" do
    get "/open/mailer", generate_email_file_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when GET open#mailer.json" do
    get "/open/mailer.json", generate_email_file_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when POST open#mailer" do
    post "/open/mailer", generate_email_file_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when POST open#mailer.json" do
    post "/open/mailer.json", generate_email_file_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end

  it "should receive [deliver..] when GET campaigns#listener" do
    get "/campaigns/listener", generate_mailtest_files_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when GET campaigns#listener.json" do
    get "/campaigns/listener.json", generate_mailtest_files_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when POST campaigns#listener" do
    post "/campaigns/listener", generate_mailtest_files_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
  it "should receive [deliver..] when POST campaigns#listener.json" do
    post "/campaigns/listener.json", generate_mailtest_files_and_params

    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res["code"]).to eq(1)
    expect(res["info"]).to eq("deliver...")
  end
end
