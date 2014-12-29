#encoding: utf-8

desc "crontab operation."
namespace :crontab do
  desc "crontab jobs list"
  task :list => :crond do
    puts @crontab.list
  end

  task :exist => :crond do
    puts @crontab.whether_job_exist?(@job)
  end

  task :add => :crond do
    if @crontab.whether_job_exist?(@job)
      puts "job alread exist!"
    else
      @crontab.add(@job)
    end
    puts @crontab.list
  end

  task :remove => :crond do
    @crontab.remove(@job)
    puts @crontab.list
  end

  task :job => :crond do
    puts @job
  end
end
