#encoding: utf-8
class Cpanel::LogController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/log"
  set :layout, :"../layouts/layout"
  before do
    unless login?
      flash[:warnging] = "please login."
      redirect "/"
    end
  end

  get "/" do
    begin
      file_path = File.join(Setting.mailgates.path.log, "mgmailerd.log")
      regexp = /\[(.*?)\]\s+\[(.*?)\] Mail\.RR\s(.*?\s*->\s*.*?)\s\((.*?)\)\[(.*)\]\[(.*?)\]\[(.*?)\]\[(.*?)\]/

      @datas = IO.readlines(file_path).last(50).map do |line|
        match = line.scan(regexp)

        if match[0] and match[0].size == 8
          timestamp, emailfile, from_to, subject, result, mgham, mgtaglog, charset = match[0]
          from, to = from_to.split(/->/).map { |str| str.gsub(/<|>/, "").strip } rescue ["", ""]

          from = from.scan(/.*?_(\d+)_0@(.*)/)[0].join("/") rescue from if from
          to   = to.scan(/.*?_(\d+)_0@(.*)/)[0].join("/") rescue to if to
          if subject.start_with?("Returned Mail:")
            result  = result + "<br>subject: " + subject
            _regexp = /(Returned\sMail\:\s\w+)/
            _match = subject.scan(_regexp)
            subject = _match ? _match[0][0] : subject[0..20]
          end
          {timestamp: timestamp.split.last, emailfile: emailfile, from: from, to: to,
           subject: subject, result: result, mgham: mgham, mgtaglog: mgtaglog, charset: charset}
        else
          {raw: line}
        end
      end.reverse
    rescue => e
      @errors = e.backtrace
      @errors.unshift(e.message)
    end

    template = @datas ? :index : :error
    haml template, layout: settings.layout
  end

  # Get /log/other
  get "/other" do
    filepath = File.join(ENV["APP_ROOT_PATH"], "log/unicorn.log")
    @unicorn_datas = read_log_with_shell("tail -n 100 %s" % filepath)
    filepath = File.join(ENV["APP_ROOT_PATH"], "log/unicorn_error.log")
    @error_datas = read_log_with_shell("tail -n 100 %s" % filepath)
    filepath = File.join(ENV["APP_ROOT_PATH"], "log/nohup.log")
    @nohup_datas = read_log_with_shell("tail -n 50 %s" % filepath)
    filepath = File.join(ENV["APP_ROOT_PATH"], "log/crontab.log")
    @crontab_datas = read_log_with_shell("tail -n 50 %s" % filepath)

    haml :other, layout: settings.layout
  end

  private
    def read_log_with_shell(command)
      IO.popen(command) do |stdout| 
          stdout.readlines#.reject(&method) 
      end.unshift($?.exitstatus.zero?)
    end
end
