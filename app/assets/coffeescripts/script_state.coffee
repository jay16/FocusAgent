#encoding: utf-8
window.ScriptState =
  showCommand: (input) ->
    App.input_operation(input, ".table .command")
  showComment: (input) ->
    App.input_operation(input, ".table .comment")
