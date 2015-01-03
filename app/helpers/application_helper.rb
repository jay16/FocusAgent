require "cgi"
module ApplicationHelper

  def flash_message
    return if !defined?(flash)
    return if flash.empty?
    # hash key must be symbol
    hash = flash.inject({}) { |h, (k, v)| h[k.to_s] = v; h; }
    # bootstrap#v3 [alert] javascript plugin
    flash.keys.map(&:to_s).grep(/warning|danger|success/).map do |key|
      #close = link_to("&times;", "#", class: "close", "data-dismiss" => "alert")
      #tag(:div, {content: "#{close}#{hash[key]}", class: "alert alert-#{key}", role: "alert" }) 
     tag(:div, hash[key], { :class => "alert alert-#{key}" })
    end.join

     #close = link_to("x", "#", { :class => "close", "data-dismiss" => "alert" })
  end

  # execute linux shell command
  # return array with command result
  # [execute status, execute result] 
  def run_command(shell, whether_show_log=true, whether_reject_empty=true)
    result = IO.popen(shell) do |stdout| 
        stdout.readlines#.reject(&method) 
    end.map { |l| l.is_a?(String) ? string_format(l) : l }
    status = $?.exitstatus.zero?
    if !status or whether_show_log
      shell  = string_format(shell).split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      resstr = (result || ["bash: no output"]).map { |line| "\t\t" + line }.join
      puts "%s\n\t\t==> %s\n%s\n" % [shell, status, resstr]
    end
    return result.unshift(status)
  end 

  def string_format(str)
    str.gsub(ENV["APP_ROOT_PATH"], "!~")
  end

  def ps_result(pid)
    # USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND
    # 0    1   2    3    4   5   6  7    8       9    10
    command = "ps aux | grep %s | grep -v 'grep'" % pid.to_s.strip
    status, *result = run_command(command)

    if result.empty?
      ["bash: no output"]
    else
      result.map do |process|
        user, pid, cpu, mem, vsz, rss, tt, stat, started, time, *command = process.split(/\s+/)
        [user, pid, cpu, mem, vsz, rss, tt, stat, started, time, command.join(" ").gsub(ENV["APP_ROOT_PATH"], "!~")]
      end.find { |p| p[1].strip == pid.to_s.strip }
    end
  end

  def agent_process_info
    title = %x{ps aux | grep PID | grep -v 'grep'}.split(/\n/).first.split
    watch_dog_pid = IO.read(File.join(ENV["APP_ROOT_PATH"], "tmp/pids/watch_dog.pid")).strip
    [title.unshift("Type"),
     ps_result(Process.pid).unshift("unicorn"),
     ps_result(watch_dog_pid).unshift("nohup")]
  end

  def crontab_jobs_list
    command = "cd %s && bundle exec rake crontab:list" % ENV["APP_ROOT_PATH"]
    status, *jobs = run_command(command)
    jobs = ["crontab: no jobs for %s" % run_command("whoami")] if jobs.empty?
    return jobs
  end

  def raw(html)
    return CGI.escapeHTML(html)
  end
  def str2time(datestr, format="%Y-%m-%d %H:%M:%S")
    return DateTime.strptime(datestr, format).to_time
  end

  def pool_data_info(type, timestamp = Time.now.strftime("%Y%m%d"))
    pool_data_path = File.join(ENV["APP_ROOT_PATH"], Setting.pool.data, timestamp)
    pool_data_file = File.join(pool_data_path, type + ".csv")
    if not File.exist?(pool_data_file)
      ["nodata", "nodata"]
    else
      lines = IO.readlines(pool_data_file)
      [lines[-1].split(",")[0], lines.count]
    end
  end

  def pool_bad_info(type, timestamp = Time.now.strftime("%Y%m%d"))
    pool_bad_path = File.join(ENV["APP_ROOT_PATH"], Setting.pool.bad, timestamp)
    if not File.exist?(pool_bad_path)
      ["nodata", "nodata"]
    else
      files = Dir.glob(pool_data_path + "/*.csv")
      ["", files.count]
    end
  end

  def rc_local_lines
    command = "cat /etc/rc.d/rc.local | grep %s" % ENV["APP_ROOT_PATH"]
    status, *lines = run_command(command)
    return lines || ["bash: no output"]
  end

  def bash_profile_lines
    command = "cat ~/.bash_profile | grep %s" % RUBY_VERSION
    status, *lines = run_command(command)
    return lines || ["bash: no output"]
  end

  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  # check remote client whether is mobile
  # define different layout
  def mobile?
    agent_str = request.env["HTTP_USER_AGENT"].to_s.downcase
    return false if agent_str =~ /ipad/
    agent_str =~ Regexp.new(MOBILE_USER_AGENTS)
  end
end
