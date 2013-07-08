#encoding: utf-8
require 'resque'

#负责与server交互
class MailerController < ApplicationController
  
  def listener
    campaign_id  =  params[:cid]   #campaign_id活动id
    server_time  =  params[:sadate] #server or agent date 服务器发送消息时间，与本地时间对比，避免时区误差等错误
    mail_type    =  params[:mail_type]
    remote_ip    =  request.remote_ip              #发送请求服务器ip
    browser      =  request.env["HTTP_USER_AGENT"] #发送请求服务器浏览器
    
    mail_type = mail_type.chomp.to_i if mail_type 
    #服务器请求信息
    server = {
      :server      => remote_ip,
      :campaign_id => campaign_id,
      :mail_type   => mail_type,
      :server_date => server_time,
      :local_date  => Time.now.to_i,
      :remote_ip   => remote_ip,
      :browser     => browser,
      :state_num   => 0
    }
    
    #默认反馈信息
    feedback = {
      :pg     => -1,
      :state  => -1,
      :info   => nil,
      :sadate => Time.now.to_i
    }
    time_dif = Time.now.to_i - server_time.to_i 
    puts "*"*100
    puts time_dif

    if campaign_id then
      #listener = Listener.create(server)
      #stage_num =listener.stage_num
      #listener.pgress.create({:stage_num => stage_num,:stage_str => "setup luxer"})
      #listener.update_attribute(:stage_num,stage_num+1)
      listener = nil 
      Resque.enqueue(Luxer,campaign_id,mail_type,listener)
      feedback[:pg]    = 1
      feedback[:state] = 0
    elsif  time_dif/60 > 10
      #时差大于10分钟时，执行搬信动作，但不执行发信，
      #同时反馈信息中提出警示
      feedback[:info] = "Time Dif: #{time_dif} s"
    end
    
    respond_to do |format|
      format.json { render :json => feedback.to_json }
    end
  end

  def sender
    
  end
  
  def chk
    require "open-uri" 
    require 'json'
    
    sdate = Time.now.to_i
    url = "http://166.63.126.33:3456/mailer/listener.json?cid=143&sdate=#{sdate}&mail_type=0"
    html_response = nil  
    open(url, 'r', :read_timeout=>1) do |http|  
      html_response = http.read  
    end  
    json_body = JSON.parse(html_response)
    org_id = json_body["org_id"]
    
    render :json => json_body
  end
  
  
  def chklog
      campaign_id = 143
      #假设所有mq正常启动
      @mails = MailTester.where("campaign_id = #{campaign_id}")
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
      render :text => "OVER"
  end
  def glob
    campaign_id= 143
      puts "*"*100
      local_path  = "/home/webmail/focus_tar"
      tar_path = File.join(local_path,"#{campaign_id}")
      domains = Array.new
      emails  = Array.new
      Dir.foreach(tar_path) do |dir|
        next if dir == "." or dir == ".."
        dir_path = File.join(tar_path,dir)
        #正常情况下，此层不应有emal源文件
        emails.push(dir_path) if File.file?(dir_path) and File.extname(dir_path).downcase == ".eml"
        domains.push({:domain => dir, :path => dir_path}) if File.directory?(dir_path)
      end
      
      @mqueues = Mqueue.all
      mq_num = @mqueues.size
      domains.each do |hash|
        puts %Q{current Email Domain: #{hash[:domain]}}
        Dir.foreach(hash[:path]) do |file|
          eml_path = File.join(hash[:path],file)
          next unless File.file?(eml_path) and File.extname(eml_path).downcase == ".eml"
          mq_wait  = "nil"
          while !File.exist?(mq_wait) 
            mq_index = rand(mq_num)
            mqueue   = @mqueues[mq_index]
            mq_wait  = File.join(mqueue.mqpath,"wait")
            if File.exist?(mq_wait) then
              MailTester.create({
                :campaign_id => campaign_id,
                :domain      => hash[:domain],
                :eml_file    => eml_path,
                :mqpath      => mq_wait
                }).save
              puts %Q{MV #{eml_path} -> #{mq_wait}}
              FileUtils.cp(eml_path,mq_wait)
            else
              puts "ERROR:NOT EXIST - #{mq_wait}"
            end
          end
        end
      end
      puts "*"*100
    render :text => "over"
    
  end
  def xzvf
    campaign_id = 143      
    server_host = "220.248.30.60"
    server_path = "/home/webmail/focus_tar/#{campaign_id}.tar.gz"
    local_path  = "/home/webmail/focus_tar"
    
    username = "webmail"
    password = "Webmail_01"
    tar_path = File.join(local_path,"#{campaign_id}.tar.gz")
    if File.exist?(tar_path)
      puts "tar -xzvf"
      if system("tar -xzvf #{tar_path} -C #{local_path}")
        puts "tar -xzvf over"
        #FocusAgent::MailTest.nurser(campaign_id)
      end
    end
    render :text => "over"
  end
  def replyer
  end
end
