require 'logger'
require 'fileutils'
require 'yaml/store'
require 'yaml'
module FocusAgent
  class SendMail

    def self.fork(domain)

      trap("INT") do
	  STDERR.puts "sub pid #{$$} Control-C"
	  exit 2
      end

      #if ARGV.length < 1 then
      #  puts "please offer domain"
      #  exit
      #end
      #domain = ARGV[0].chomp

      agent_path ="/home/webmail/FocusAgent"
      base_path = File.join(agent_path,"SendMail")

      #domains 邮箱域名 eths使用对应eth limit时速
      domains = %w(qq 163 sina yahoo sohu gmail tom hotmail other)
      eths    = %w(qq 163 sina 163 126 126 126 126 126)
      limits  = %w(120 120 20 30 100 20 10 30 50)
      stop_time = 30*60

      unless domains.include?(domain) then
	puts "[#{domain}] no in #{domains.to_s}"
	exit
      end

      #每个domain的16个端口搬信信息实时记录其状态
      mv_logger  = Logger.new(File.join(agent_path,"log","sendMail_#{domain}.log"))
      #每个domain的16个端口独立实时记录其状态
      ports_path = File.join(agent_path,"log","#{domain}_ports.store")
      ports_yaml = YAML::Store.new(ports_path)
      #每个domain的16个端口被禁&解禁单独记录
      ports_history = Logger.new(File.join(agent_path,"log","#{domain}_ports_history.hy"))
      #mqueue/wait SenMail/org 每隔指定时扫描一次
      #mv_wait_log   = Logger.new(File.join(agent_path,"log","#{domain}_wait_send.log"))

      ports = []
      #存在则读取，不存在则创建、并初始化
      if File.exist?(ports_path) then
	ports_load = YAML.load_file(ports_path)
	(0..15).each_with_index do |port, index| 
	  ports.push(ports_load[index])
	end
      else
	ports_yaml.transaction do
	  (0..15).each_with_index do |port, index|
	    port_init = {:port => index, :is_valid => 1, :untime => 0, :lasteml => '', :times => 0, :lastlog => '' }
	    ports.push(port_init)
	    ports_yaml[index] = port_init
	   end
	end
      end
      mv_logger.formatter = proc do |severity, datetime, progname, msg|
       "#{datetime}: #{msg}\n"
      end
      mv_logger.datetime_format = "%Y-%m-%d %H:%M:%S"


      keywords = nil
      case domain
      when "qq" 
	keywords = %w(Connection unavailable content)
      when "163" 
	keywords = %w(Connection unavailable content)
      when "sina" 
	keywords = %w(rejected blocked content)
      when "yahoo"
        keywords = %w(allowed accepted ip)
      when "sohu"
        keywords = %w(client blocked)
      end 

      dindex = domains.index(domain)
      eth    = eths[dindex]
      limit  = limits[dindex].to_i
      mv_logger.info "ETH is:#{eth} limit is:#{limit}/h keywords:#{keywords.to_s}"
      ports.each_with_index do |p, i|
	puts "#{i} - #{p.to_s}"
      end
      glob_index = 0
      domain_path = File.join(base_path,domain)
      while(!(orgs = Dir.entries(domain_path).reject { |d| d == "." or d == ".." }).empty?)
	orgs.each do |org|
	  next if org.nil?
	  org_path = File.join(domain_path,org)
	  next unless File.exist?(org_path)
	  puts org_path
	  mails=Dir.entries(org_path).grep(/.eml/)
	  if  mails.size == 0
	    begin
	      Dir.delete(org_path)
	    rescue => e
	     puts e.message
	    end
	    puts "next"*10
	    next
	  end
	  mail = mails[Integer(rand(mails.size))]
	  mail_path = File.join(org_path,mail)
	  
	  unless keywords.nil? then
	    #检查被禁端口是否间隔stop_time
	    valids = ports.select { |v| v[:is_valid] == 1 }
	    unvalids = ports - valids
	    unvalids.each do |unvalid|
	      if (Time.now.to_i-unvalid[:untime])>= stop_time*unvalid[:times].to_i then
		 unvalid[:is_valid] = 1
		 ports_yaml.transaction do
		    ports_yaml[unvalid[:port]][:is_valid] = 1
		 end
		 valids = ports.select { |v| v[:is_valid] == 1 }
		 ports_history.info("[allow][#{domain}][#{unvalid[:port]}][wait:#{stop_time*unvalid[:times].to_i}][#{Time.now.strftime('%y%m%d%H%M%S')}][all][#{valids.size}]")
		 puts "REMOVE FORBID:#{unvalid}  - THEN VALIDS:#{valids.size}"
		 mv_logger.info("REMOVE FORBID:#{unvalid}  - THEN VALIDS:#{valids.size}")
	      end
	    end
	  end

	  valids = ports.select { |v| v[:is_valid] == 1 }
	  if valids.empty? then
	    sleep(stop_time)
	    next
	  end
	  vindex = glob_index%valids.size #Integer(rand(valids.size))
	  puts "vindex:#{vindex}"
	  port = valids[vindex]
	    
	  eth_port = port[:port] 
	  sptime    = (Float(60*60)/Float(limit)/Float(valids.size)).round(5)
	  puts "port:#{eth_port}-sptime:#{sptime}"
	  mq_wait = "/webmail/mqueue_#{eth}_eth#{eth_port}/wait"
	  mq_log  = "/webmail/mqueue_#{eth}_eth#{eth_port}/log/mgmailerd_#{eth}_eth#{eth_port}.log"
	  
	  unless keywords.nil? then
	    #检查上封信是否被禁,第一次仅检查日志最一笔
	    lasteml = port[:lasteml] 
	    if lasteml.nil? then
	      this_hour = Time.now.strftime("%y/%m/%d %H")
              begin
      	      lastlog = File.readlines(mq_log).grep(/#{this_hour}/)
              rescue => e
              puts  e.backtrace.to_s
              blacks = []
              else
	      blacks  = lastlog.grep(/#{keywords.join('|')}/)
              end
	    else
	      puts "lastEmail:#{lasteml}"
              begin
	      lastlog = File.readlines(mq_log).grep(/#{lasteml}/)
              rescue => e
              puts e.backtrace.to_s
              blacks = []
              else
	      blacks  = lastlog.grep(/#{keywords.join('|')}/)
              end
	    end
	    if blacks.size >=1 then
	       port[:is_valid] = 0
	       port[:untime]   = Time.now.to_i
	       port[:times]  = port[:times].to_i + 1
	       port[:lastlog] = blacks.join("\n")
		 ports_yaml.transaction do
		    ports_yaml[port[:port]][:is_valid] = port[:is_valid]
		    ports_yaml[port[:port]][:lasteml]  = port[:lasteml]
		    ports_yaml[port[:port]][:untime]   = port[:untime]
		    ports_yaml[port[:port]][:lastlog]  = blacks.join("\n")
		 end
	       valids = ports.select { |v| v[:is_valid] == 1 }
	       puts "ADD FORBID:#{port} - THEN VALIDS:#{valids.size} - KEYWORDS:#{keywords.to_s}"
	       ports_history.info("[forbid][#{domain}][#{port[:port]}][#{Time.now.strftime('%y%m%d%H%M%S')}][all][#{valids.size}][#{blacks.join('\n')}")
	       mv_logger.info("VALIDS:#{valids.size} - KEYWORDS:#{keywords.to_s} - ADD FORBID:#{port}")
	       next
	    end
	  end
	    unless File.exist?(mq_wait) then
	      puts "#{mq_wait} NOT EXIST"
	      mv_logger.info "#{mq_wait} NOT EXIST"
	      next
	    end
	    unless File.exist?(mq_log) then
	      puts "#{mq_log} NOT EXIST"
	      mv_logger.info "#{mq_log} NOT EXIST"
	      next
	    end

	    port[:lasteml] = mail
	    begin
	      FileUtils.mv(mail_path,mq_wait)
	    rescue => e
	      puts e.message
	      mv_logger.fatal(e)
	    end
	    str = "[limit:#{limit}]:[wait:#{sptime}s]:[all:#{(Float(sptime)*Float(mails.size-1)/60.0).round(2)}m][#{domain}][#{org}][#{mail}]=>[#{eth}][#{port[:port]}]"
	    puts str
	    mv_logger.info(str)
	    glob_index += 1
	    sleep(sptime)
	end
      end

    end
  end
end
