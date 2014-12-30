(function() {
  window.ScriptState = {
    showCommand: function(input) {
      return App.input_operation(input, ".table .command");
    },
    showComment: function(input) {
      return App.input_operation(input, ".table .comment");
    }
  };

}).call(this);
