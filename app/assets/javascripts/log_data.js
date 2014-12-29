(function() {
  window.LogData = {
    _operation: function(input, klass) {
      if (App.checkboxState(input)) {
        App.checkboxUnChecked(input);
        $(klass).removeClass("hidden");
      } else {
        App.checkboxChecked(input);
        $(klass).addClass("hidden");
      }
      return $(".check-info").removeClass("hidden").html($(klass).length + "行数据受影响.");
    },
    showRaw: function(input) {
      return LogData._operation(input, ".log-datas .raw");
    },
    showNormal: function(input) {
      return LogData._operation(input, ".log-datas .normal");
    },
    showReason: function(input) {
      return LogData._operation(input, ".log-datas .reason");
    }
  };

}).call(this);
