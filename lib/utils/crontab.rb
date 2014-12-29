#encoding: utf-8
class Crontab
  def initialize(tmp_path, yn=true)
    raise "[Abort] - Crontab tmp path not exist!" unless File.exist?(tmp_path)
    @crontab_org_conf = File.join(tmp_path, "crontab_org.conf")
    @crontab_new_conf = File.join(tmp_path, "crontab_new.conf")
    @whether_show_log = yn
  end

  def execute!(shell, whether_show_log=@whether_show_log)
    _result = IO.popen(shell) do |stdout| 
      stdout.reject(&:empty?) 
    end.unshift($?.exitstatus.zero?)
    if whether_show_log
      _shell  = shell.gsub(ENV["APP_ROOT_PATH"], "=>").split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      _status = _result[0]
      _res    = _result.length > 1 ? _result[1..-1].map { |line| "\t\t" + line }.join  : "\t\tbash: no output."
      puts "%s\n\t\t==> %s\n%s\n" % [_shell, _status, _res]
    end
    return _result
  end 

  def write_jobs_to_conf(jobs)
    command = "true > %s" % @crontab_new_conf
    execute!(command)
    File.open(@crontab_new_conf, "a+") do |file|
      jobs.each { |job| file.puts(job) }
    end
  end

  def reload_crontab_with_new_conf
    command = "crontab %s" % @crontab_new_conf
    execute!(command)
  end

  def reload_crontab_with_org_conf
    command = "crontab %s" % @crontab_org_conf
    execute!(command)
  end

  def whether_job_exist?(command)
    !list.find_all { |job| job == command }.count.zero?
  end

  def list
    command = "crontab -l > %s" % @crontab_org_conf
    execute!(command)
    IO.readlines(@crontab_org_conf).map(&:strip)
  end

  def add(command)
    jobs = list
    jobs.push(command)
    write_jobs_to_conf(jobs)

    status, *result = reload_crontab_with_new_conf
    if status
      puts "\tadd job successfully."
      jobs = IO.readlines(@crontab_new_conf)
    else
      puts "\tadd job fail. and restore jobs."
      reload_crontab_with_org_conf
      jobs = list
    end
    jobs.unshift(status)
  end

  def remove(command)
    jobs = list
    jobs.delete_if { |job| job == command }
    write_jobs_to_conf(jobs)
    
    status, *result = reload_crontab_with_new_conf
    if status
      puts "\tremove job successfully."
      jobs = IO.readlines(@crontab_new_conf)
    else
      puts "\tremove job fail. and restore jobs."
      reload_crontab_with_org_conf
      jobs = list
    end
    jobs.unshift(status) 
  end
end

