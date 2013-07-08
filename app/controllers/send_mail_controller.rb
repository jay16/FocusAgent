#encoding: utf-8

class SendMailController < ApplicationController
  def start_old
    base_path = "/home/webmail/FocusAgent/SendMail"
    domains   = %w(qq 163 sina other hotmail gmail yahoo tom sohu)

    str = "ps -ef | grep mail_sender | grep -v grep"
    runs = run_command(str,domains)
    unruns = domains - runs
    unruns.each do |dd|
      if chkMail(dd,base_path) > 0 then
        FocusAgent::SendMail.fork(dd)
        sleep(0.5)
      end
    end
    
  end
  def start
    base_path = "/home/webmail/FocusAgent/SendMail"
    domains   = %w(qq 163 sina other hotmail gmail yahoo tom sohu)
    rbfile    = "/home/webmail/FocusAgent/rb/mail_sender.rb"
    
    str = "ps -ef | grep mail_sender | grep -v grep"
    runs = run_command(str,domains)
    unruns = domains - runs
    unruns.each do |dd|
      if chkMail(dd,base_path) > 0 then 
        system("nohup /usr/local/bin/ruby #{rbfile} #{dd} > #{base_path}/mynohup.out 2>&1 &")
        sleep(0.5)
      end
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def stop
    
    respond_to do |format|
      format.js
    end
  end
 
  def sub_files(path,type)
    Dir.entries(path).reject do |d|
      d == "." or d == ".." or (type == 'f' ? File.directory?(File.join(path,d)) :File.file?(File.join(path,d)))
    end
  end
  
  def chkMail(domain,base_path)
    domain_path = File.join(base_path,domain)
    dd = Array.new; mail_size = 0;
    orgs = sub_files(domain_path,'d')
    orgs.each do |org|
      org_path = File.join(domain_path,org)
      mails = sub_files(org_path,'f').grep(/.eml/)
      dd.push({:org => org, :size => mails.size});mail_size += mails.size
    end
    puts "[#{domain}:#{mail_size}][#{dd.to_s}]" if mail_size > 0
    return mail_size
  end

  
  def run_command(cmd, domains, exit_on_error=true)
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
end
