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
    @jobs.each do |job|
      @crontab.remove(job)
    end
    puts "\ncrontab jobs list:\n"
    puts @crontab.list
  end

  task :jobs => :crond do
    puts @jobs
  end
end
