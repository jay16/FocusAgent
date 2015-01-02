#encoding: utf-8

desc "crontab operation."
namespace :crontab do
  desc "crontab jobs list"
  task :list => :crond do
    puts @crontab.list
  end

  task :exist => :crond do
    @jobs.each do |job|
      status = @crontab.whether_job_exist?(job) ? "exist" : "not exist"
      puts "job command: %s\ncrontab status: %s\n" % [job, status]
    end
  end

  task :add => :crond do
    @jobs.each do |job|
      if @crontab.whether_job_exist?(job)
        puts "job command: %s\ncrontab status: exit\n" % job
      else
        @crontab.add(job)
      end
    end
    puts "\ncrontab jobs list:\n"
    puts @crontab.list
  end

  task :remove => :crond do
    @crontab.remove(@jobs + @old_jobs)

    puts "\ncrontab jobs list:\n"
    puts @crontab.list
  end

  task :jobs => :crond do
    puts @jobs
    puts "# /etc/rc.d/rc.local"
    puts "su - root -c 'cd /home/work/focus_mail_agent && /bin/sh chkdog.sh'"
  end
end
