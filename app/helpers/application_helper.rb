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

  def ps_result(title, pid)
    ps = "ps aux | grep #{pid} | grep -v 'grep'"
    status, *result = run_command(ps)
    keywords = ["ruby", ENV["APP_ROOT_PATH"],"passenger", "thin"]
    result = result.find_all{ |i| keywords.any?(&i.method(:include?)) }
    if result.empty?
      ["result is empty - ", ps].join
    else
      row = result.first.split
      row.first(title.length-1).push(row.last(row.length-title.length+1).join(" "))
    end
  end

  def agent_process_info
    status, *result = run_command("ps aux | grep PID | grep -v 'grep'")
    title = result.first.split
    main_process = ps_result(title, Process.pid)

    %w(agent_wget agent_mv2wait).map do |pid_file|
      pid_path    = File.join(ENV["APP_ROOT_PATH"],"tmp", [pid_file, "pid"].join("."))
      if File.exist?(pid_path) and !(lines = IO.readlines(pid_path)).empty?
        ps_result(title, lines[0].strip)
      else
        ["pid_file not found - ", pid_path].join
      end
    end.unshift(main_process).unshift(title)
  end
end
