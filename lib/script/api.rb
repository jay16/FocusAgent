#encoding: utf-8
require 'fileutils'
require 'yaml'
require 'yaml/store'
require 'json'                                                                                                                                                         
require "open-uri"
require 'cgi'
require 'net/http'
require 'uri'

module FocusApi
  class Mailer

    @api_path = "/home/work/focus_agent/public/openapi"
    @server_ip = "main.intfocus.com"
    @yaml_path = File.join(@api_path,"api_sendmail.yaml")
    @wait_path = File.join("/mailgates","mqueue","wait")
    @log_path  = File.join("/mailgates","mqueue","log","mgmailerd.log")


    def self.deliver(email,tar_name,md5,strftime)
      @strftime = strftime
      @email    = email
      puts "*"*10
      if download(tar_name,md5) then
        send_mail(tar_name.gsub(".tar.gz",""))
        send_back
      end
       
      return "fail" 
    end
   
 
    def self.download(tar_name,md5)
      focus_server = "http://#{@server_ip}/openapi/"
      tar_url      = "#{focus_server}#{tar_name}"
      puts "tar url:#{tar_url}"

      wget_str = "cd #{@api_path} && wget #{tar_url}" 
      run_command(wget_str)
     
      tar_path = File.join(@api_path,tar_name)
      if File.exist?(tar_path) then
         md5_str = "cd #{@api_path} && md5sum #{tar_name}"
         ret = run_command(md5_str)
         md5_res = ret[0].split(" ")[0].chomp
         if md5_res == md5 then
           tar_str = "cd #{@api_path} && tar -xzvf #{tar_name}"
           run_command(tar_str)
           return true
         else
           puts "MD5 Can't Match!"
           return false
         end
      else
         puts "Wget Fail!"
         return false
      end
    end
    
    def self.send_back
      @yaml_load = YAML.load_file(@yaml_path)
      log  = @yaml_load[@email][:log]
       
     # retrain = "read.mailhok.com"
      focus_server = "http://#{@server_ip}/open/getlog"
      log =  CGI::escape(log)
      params_str   = "format=json&email=#{@email}&strftime=#{@strftime}&log=#{log}"

      url = "#{focus_server}?#{params_str}"
                                                                                                                                                                       
      uri = URI.parse(focus_server)
      header = {'Content-Type' => 'application/json'}
      user = {format: "json", email: @email,log: log}

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = user.to_json

      begin
        response = http.request(request)
      rescue => e
        puts e.message
        json_body = { :connection => "false",
          :agent  => focus_server,
          :params => user.to_json, 
          :detail => e.backtrace
        }
      else
        json_body = response.body
      end

      return json_body
    end

    def self.send_mail(email)
          
       @yaml_save = YAML::Store.new(@yaml_path)
       @yaml_save.transaction do
          @yaml_save[@email] = {}
       end 

       mail_base = @api_path #Rails.root.join("public/openapi") 
       mail_path = File.join(mail_base, email)
       FileUtils.mv(mail_path,@wait_path)

       while File.exist?(File.join(@wait_path,email))
        sleep(1) 
       end
       log = ""
       while log.length == 0
         sleep(1)
         log = File.readlines(@log_path).grep(/#{email}/).join("-")
       end

       @yaml_save.transaction do
          @yaml_save[@email][:log]     = log
       end 
       return log
    end
    def self.run_command(cmd, exit_on_error=false)                                                                                                                     
      ret = []
      IO.popen(cmd) do |stdout|
        stdout.each do |line|
          next if line.nil?
          ret << line
        end 
      end 
    
      if exit_on_error && ($?.exitstatus != 0)
        $stderr.puts "command failed:\n#{cmd}"
        return []
      end 
    
      ret 
    end 

  end
end


if(ARGV.size>=4)
  email    = ARGV[0].chomp
  tar_name = ARGV[1].chomp
  md5      = ARGV[2].chomp
  strftime = ARGV[3].chomp
#    strftime =  "20130727132446"
#    email    = "solife_li@163.com"
#    tar_name = "solife_li-163.com_20130810180943.eml.tar.gz"
#    md5      = "b6aed97d0e8034bbd88b59ef1c946b7f"
  begin
  FocusApi::Mailer.deliver(email,tar_name,md5,strftime)
  rescue => e
   File.open("error.log","a") do |file|
    file.puts e.message
    file.puts e.backtrace
   end
  end
else
  puts "ARGV"*10
  puts ARGV.to_s
end

