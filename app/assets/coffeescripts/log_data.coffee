#encoding: utf-8
window.LogData =
  _operation: (input, klass) ->
    if App.checkboxState(input)
      App.checkboxUnChecked(input)
      $(klass).removeClass("hidden")
    else
      App.checkboxChecked(input)
      $(klass).addClass("hidden")
    $(".check-info").removeClass("hidden").html($(klass).length+"行数据受影响.")

  showRaw: (input) ->
    LogData._operation(input, ".log-datas .raw")
  showNormal: (input) ->
    LogData._operation(input, ".log-datas .normal")
  showReason: (input) ->
    LogData._operation(input, ".log-datas .reason")
