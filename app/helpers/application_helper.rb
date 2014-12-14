require "cgi"
module ApplicationHelper

  def notice_message
     #close = link_to("x", "#", { :class => "close", "data-dismiss" => "alert" })
     tag(:div, flash[:notice], { :class => "alert alert-success" }) if flash[:notice]
  end

  # execute linux shell command
  # return array with command result
  # [execute status, execute result] 
  def run_command(cmd)
    IO.popen(cmd) do |stdout|
      stdout.reject(&:empty?)
    end.unshift($?.exitstatus.zero?)
  end 

  def ps_result(pid)
    status, *result = run_command("ps aux | grep PID | grep -v 'grep'")
    title = result.first.split
    
    ps = "ps aux | grep #{pid} | grep -v 'grep'"
    status, *result = run_command(ps)
    result.map do |line|
      row = line.split
      row.first(title.length-1)
        .push(row.last(row.length-title.length+1).join(" "))
    end.unshift(title)
  end

  def agent_process_info
    ps_result(Process.pid)
  end

  def raw(html)
    CGI.escapeHTML(html)
  end
  def str2time(datestr, format="%Y-%m-%d %H:%M:%S")
    DateTime.strptime(datestr, format).to_time
  end

  def pool_data_info(type, timestamp = Time.now.strftime("%Y%m%d"))
    pool_data_path = File.join(ENV["APP_ROOT_PATH"], Setting.pool.data, timestamp)
    pool_data_file = File.join(pool_data_path, type + ".csv")
    if not File.exist?(pool_data_file)
      ["nodata", "nodata"]
    else
      lines = IO.readlines(pool_data_file)
      [lines[-1].split(",")[0], lines.length]
    end
  end
end
