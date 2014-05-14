#encoding: utf-8
require 'fileutils'
require 'yaml'
require 'yaml/store'
require 'json'
require "open-uri"
require 'cgi'
require 'net/http'
require 'uri'

module FocusAgent
  module MailTest
    @mail_path = "/home/work/focus_agent/public/mailtem/mailtest" 
    @server_ip = "10.160.22.79"
    #@server_ip = "112.124.22.136:3000"
    @wait_path = File.join("/mailgates","mqueue","wait")
    @log_path  = File.join("/mailgates","mqueue","log","mgmailerd.log")

    def self.perform(filename,md5)
      tar_name = "#{filename}.tar.gz"

      if download(tar_name,md5) then
        deliver(filename)
      else
        puts "download ERROR!" 
      end
    end
    
    def self.download(tar_name,md5)
      focus_server = "http://#{@server_ip}/mailtem/mailtest/"
      tar_url      = "#{focus_server}#{tar_name}"
      puts "tar url:#{tar_url}"

      wget_str = "cd #{@mail_path} && wget #{tar_url}" 
      run_command(wget_str)
     
      tar_path = File.join(@mail_path,tar_name)
      if File.exist?(tar_path) then
         md5_str = "cd #{@mail_path} && md5sum #{tar_name}"
         ret = run_command(md5_str)
         md5_res = ret[0].split(" ")[0].chomp
         if md5_res == md5 then
           tar_str = "cd #{@mail_path} && tar -xzvf #{tar_name}"
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
 
    def self.deliver(filename)
      puts "*"*100
      tar_path = File.join(@mail_path,filename)
      domains = Array.new
      emails  = Array.new
      Dir.foreach(tar_path) do |dir|
        next if dir == "." or dir == ".."
        dir_path = File.join(tar_path,dir)
        #正常情况下，此层不应有emal源文件
        emails.push(dir_path) if File.file?(dir_path) and File.extname(dir_path).downcase == ".eml"
        domains.push({:domain => dir, :path => dir_path}) if File.directory?(dir_path)
      end
      domains.uniq!
      
      domains.each do |hash|
        puts %Q{current Email Domain: #{hash[:domain]}}
        Dir.foreach(hash[:path]) do |file|
          eml_path = File.join(hash[:path],file)
          next unless File.file?(eml_path) and File.extname(eml_path).downcase == ".eml"
          FileUtils.mv(eml_path,@wait_path)
        end
      end
      puts "*"*100
    end
    
    def self.chkLOG
      #假设所有mq正常启动
      @mails = MailTester.where("log_cm is null")
      @mails.each do |mail|
        eml_file = mail.eml_file
        eml_name = File.basename(eml_file)
        mq_array = mail.mqpath.split("/")
        mq_array[-1] = "log"
        mq_eth    = mq_array[-2].split("_")
        mq_eth[0] = "mgmailerd"
        log_name  = mq_eth.join("_")+".log"
        log_path  = File.join(mq_array.join("/"),log_name)
        puts "*"*15
        puts log_path
        if File.exist?(log_path) then
           logs = File.readlines(log_path).grep(/#{eml_name}/)
           if logs.length then
             mail.log_cm = logs.join("\n")
             mail.save
           end
        else
          puts "ERROR: NOT EXist - #{log_path}"
        end
      end
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

if ARGV.length >= 2 then
  filename = ARGV[0]
  md5      = ARGV[1]
  FocusAgent::MailTest.perform(filename,md5)
else
  puts "Mail Test ARGV:#{ARGV.to_s}"
end

