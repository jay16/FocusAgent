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
      @datas = IO.readlines(file_path).last(50).map do |line|
        regexp9 = /\[(.*?)\]\s+\[(.*?)\] Mail\.RR\s<(.*?)>\s->\s<(.*?)>\s\((.*?)\)\[(.*)\]\[(.*?)\]\[(.*?)\]\[(.*?)\]/
        regexp7 = /\[(.*?)\]\s+\[(.*?)\] Mail\.RR\s->\s\((.*?)\)\[(.*)\]\[(.*?)\]\[(.*?)\]\[(.*?)\]/
        match = line.scan(regexp9)
        is_raw = 0
        if match[0] and match[0].size == 9
          timestamp, emailfile, from, to, subject, result, mgham, mgtaglog, charset = match[0]
        else
          match = line.scan(regexp7)
          if match[0] and match[0].size == 7
            timestamp, emailfile, subject, result, mgham, mgtaglog, charset = match[0]
            from, to = "", ""
          else
            is_raw = 1
          end
        end

        if is_raw.zero?
          from = from.scan(/.*?_(\d+)_0@(.*)/)[0].join("/") rescue from unless from.empty?
          if subject.length > 100
            result  = result + "<br>subject: %s" + subject
            subject = subject[0..30] 
          end
          {timestamp: timestamp.split.last,
           emailfile: emailfile,
                from: from,
                  to: to,
             subject: subject,
              result: result,
               mgham: mgham,
            mgtaglog: mgtaglog,
             charset: charset}
        else
          {raw: line}
        end
      end.reverse
    rescue => e
      @errors = e.backtrace
      @errors.unshift(e.message)
    end

    if @datas
      haml :index, layout: settings.layout
    else
      haml :error, layout: settings.layout
    end
  end

end
