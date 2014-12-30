#encoding: utf-8
window.LogData =
  _operation: (input, klass) ->
    App.input_operation(input, klass)
    $(".check-info").removeClass("hidden").html($(klass).length+"行数据受影响.")

  showRaw: (input) ->
    LogData._operation(input, ".log-datas .raw")
  showNormal: (input) ->
    LogData._operation(input, ".log-datas .normal")
  showReason: (input) ->
    LogData._operation(input, ".log-datas .reason")
