require 'fileutils'

module FocusAgent
  module MailTest

    def self.nurser(campaign_id)
      puts "*"*100
      local_path  = "/home/webmail/focus_tar"
      tar_path = File.join(local_path,"#{campaign_id}_InnerTest")
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
  end
end
