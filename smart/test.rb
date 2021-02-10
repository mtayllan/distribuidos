require "tty-prompt"

prompt = TTY::Prompt.new
key = prompt.keypress(timeout: 1)
p key
