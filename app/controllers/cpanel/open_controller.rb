#encoding: utf-8
class Cpanel::OpenController < Cpanel::ApplicationController

	# download trigger/download/move data
	# params:
	#     token: necessary
	#     timestamp: optional,yyyymmdd, default today
  get "/data" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      now = Time.now
      timestamp = params[:timestamp] || now.strftime("%Y%m%d")
      data_path = File.join(ENV["APP_ROOT_PATH"], Setting.pool.data)
      data_file = File.join(data_path, timestamp) 
      if File.exist?(data_file)
        file_name = now.strftime("%Y%m%d%H%M%S") + ".tar.gz"
        shell = "cd %s && rm %s*.tar.gz" % [data_path, timestamp]
        run_command(shell)
        shell = "cd %s && tar -czvf %s %s" % [data_path, file_name, timestamp]
        run_command(shell)
        file_path = File.join(data_path, file_name)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "data file not exist" }
        respond_with_json hash, 200
      end
    end
  end

	# download mailgates log file
	# params:
	#     token: necessary
	#     filename: optional,default "mgmailerd.log"
  get "/log" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      file_name = params[:filename] || "mgmailerd.log" 
      file_path = File.join(Setting.mailgates.path.log, file_name)
      if File.exist?(file_path)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "log file not exist" }
        respond_with_json hash, 200
      end
    end
  end

	# download mailgates archived log file
	# params:
	#     token: necessary
	#     timestamp: optional,yyyymmdd, default today(response: file not exist)
  # /mailgates/log_archive/2014_11/mgmailerd.log.141112.gz 
  get "/archived" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      timestamp = params[:timestamp] || Time.now.strftime("%Y%m%d")
      y_m = timestamp[0..3] + "_" + timestamp[4..5]
      ymd = timestamp[2..-1]
      file_name = ["mgmailerd.log",ymd,"gz"].join(".")
      file_path = File.join(Setting.mailgates.path.archived, y_m, file_name) 
      if File.exist?(file_path)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "archived file not exist" }
        respond_with_json hash, 200
      end
    end
  end


  # get webapp/nohup/crontab run state
	# params:
	#     token: necessary
  get "/process" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      hash = { code: 1, info: agent_process_info }
      respond_with_json hash, 200
    end
  end

  private
    def ps_result(pid)
      # USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND
      # 0    1   2    3    4   5   6  7    8       9    10
      script = "ps aux | grep %s | grep -v 'grep'" % pid.to_s.strip
      status, *result = run_command(script)

      if result.size > 0
        result.map do |process|
          user, pid, cpu, mem, vsz, rss, tt, stat, started, time, *command = process.split(/\s+/)
          [user, pid, cpu, mem, vsz, rss, tt, stat, started, time, command.join(" ").gsub(ENV["APP_ROOT_PATH"], "!~")]
        end.find { |p| p[1].strip == pid.to_s.strip }
      else
        ["bash: no output"]
      end
    end

    def agent_process_info
      title = %x{ps aux | grep PID | grep -v 'grep'}.split(/\n/).first.split
      watch_dog_pid = IO.read(File.join(ENV["APP_ROOT_PATH"], "tmp/pids/watch_dog.pid")).strip
      [title.unshift("Type"),
       ps_result(Process.pid).unshift("unicorn"),
       ps_result(watch_dog_pid).unshift("nohup")]
    end
end
