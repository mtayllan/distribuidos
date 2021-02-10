require "tty-prompt"

prompt = TTY::Prompt.new
while (char = prompt.keypress("Press key ?"))
  puts char
end
