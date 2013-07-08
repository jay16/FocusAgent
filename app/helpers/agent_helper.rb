require 'yaml'
module AgentHelper
  def format_time(t)
    t.strftime("%Y-%m-%d %H:%M:%S %z")
  end

  def queue_from_class_name(class_name)
    Resque.queue_from_class(Resque.constantize(class_name))
  end
  def sendMailStates
    domains = %w(qq 163 sina yahoo sohu gmail tom hotmail other)
    eths    = %w(qq 163 sina 163 126 126 126 126 126)
    limits  = %w(120 120 20 30 10 20 10 30 50)
    klass   = %w(QQ_Mover 163_Mover Sina_Mover Yahoo_Mover Sohu_Mover Gmail_Mover Tom_Mover Hotmail_Mover Other_Mover)
    
    str = "ps -ef | grep mail_sender | grep -v grep"
   # send_status  = run_command(str)
   # hasMail = chkMail
    rt    = []
    domains.each_with_index do |domain,index|
      rt.push([index,domain,limits[index],eths[index],klass[index]])
    end
    return rt
  end
  
  def run_command(cmd, exit_on_error=true)
    domains = %w(qq 163 sina yahoo sohu gmail tom hotmail other)
    ret = []
    IO.popen(cmd) do |stdout|
      stdout.each do |line|
        #puts line
        next if line.nil?
        ld = line.split[-1].chomp
        ret << ld if domains.include?(ld)
      end
    end
  
    if exit_on_error && ($?.exitstatus != 0)
      $stderr.puts "command failed:\n#{cmd}"
      return []
    end
  
    ret
  end
  
  def sub_files(path,type)
    Dir.entries(path).reject do |d|
      d == "." or d == ".." or (type == 'f' ? File.directory?(File.join(path,d)) :File.file?(File.join(path,d)))
    end
  end
  
  def chkMail
    base_path = "/home/webmail/FocusAgent/SendMail"
    domains   = %w(qq 163 sina yahoo sohu gmail tom hotmail other)
    mail_sizes = []
    domains.each do |domain|
      domain_path = File.join(base_path,domain)
      mail_size = 0;
      orgs = sub_files(domain_path,'d')
      orgs.each do |org|
        org_path = File.join(domain_path,org)
        mails = sub_files(org_path,'f').grep(/.eml/)
        mail_size += mails.size
      end
      mail_sizes.push(mail_size)
     end
    return mail_sizes
  end

  def getEthValids(domain)
    agent_path = "/home/webmail/FocusAgent"
    log_path   = File.join(agent_path,"log")
    ports_path = File.join(log_path,"#{domain}_ports.store")
     
    unknow, valids = true, []
    if File.exist?(ports_path)
      unknow = false
      store_yaml = YAML.load_file(ports_path)
      (0..15).each do |i|
	valids.push(store_yaml[i][:port])  if store_yaml[i][:is_valid].to_i == 1
      end
    end

    return [unknow, valids]
  end
end
