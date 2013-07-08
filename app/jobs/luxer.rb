require 'net/ssh'
require 'net/scp'
      
class Luxer
  @queue = "Mail-Luxer"
  
  def self.perform(campaign_id,mail_type,listener)
      tar_name = nil
      case mail_type
      when 0  #发送测试
        tar_name = "#{campaign_id}_InnerTest"
      else
        puts "*"*100
        puts "only receive mail_type = 0"
        #stage_num =listener.stage_num
        #listener.pgress.create({:stage_num => stage_num,:stage_str => "MailType is #{mail_type},only receive mail_type = 0"})
        #listener.update_attribute(:stage_num,stage_num+1)
        return false
      end
        
      server_host = "220.248.30.60"
      server_path = "/home/webmail/focus_tar/#{tar_name}.tar.gz"
      local_path  = "/home/webmail/focus_tar"
      
      username = "webmail"
      password = "Webmail_01"
        
      #通ssh登陆服务判断文件是否存在
      tar_num = 0
      Net::SSH.start( server_host, username, :password => password ) do|ssh|
        tar_num = ssh.exec!("ls #{server_path} | grep .tar.gz | wc -l " ).to_i
      end
      
      if Integer(tar_num) <= 0 
        #remote tar文件不存在
        puts "*" * 50
        puts "ERROR:remote tar not EXIT!"
        return false 
      end
      
      #若存在同名待scp文件,修改该文件名
      conflict = File.join(local_path,"#{tar_name}")   
      FileUtils.mv(conflict,"#{conflict}_#{Time.now.strftime('%y%m%d%H%M%S')}") if File.exist?(conflict)
      conflict = File.join(local_path,"#{tar_name}.tar.gz")
      FileUtils.mv(conflict,"#{conflict}_#{Time.now.strftime('%y%m%d%H%M%S')}") if File.exists?(conflict)

      #stage_num =listener.stage_num
      #listener.pgress.create({:stage_num => stage_num,:stage_str => "scp file start"})
      #listener.update_attribute(:stage_num,stage_num+1)
      
      #tar文件存在 - >scp 从服务器搬信
      puts "*" * 50
      puts "scp start"
      Net::SCP.start(server_host, username,:password => password) do |scp|
        channel =  scp.download(server_path,local_path)
        channel.wait
      end
      puts "scp over"
      #解压本地压缩包
      tar_path = File.join(local_path,"#{tar_name}.tar.gz")
      if File.exist?(tar_path)
        if system("tar -xmzvf #{tar_path} -C #{local_path}")
          case mail_type
          when 0
            puts "Nurser Get It!"
            FocusAgent::MailTest.nurser(campaign_id) 
          else
            puts "Only Deal mail_type=0,Yours Is #{mail_type}"
          end
          
        end
      else
        puts "*"*50
        puts "ERROR:TAR NOT EXIST!\n#{tar_path}"
      end

  end
  
  
end
