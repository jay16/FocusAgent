(function() {
  window.LogData = {
    _operation: function(input, klass) {
      if (App.checkboxState(input)) {
        App.checkboxUnChecked(input);
        return $(klass).removeClass("hidden");
      } else {
        App.checkboxChecked(input);
        return $(klass).addClass("hidden");
      }
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
