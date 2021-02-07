require 'socket'
require './commands'

puts 'Bem-Vindo!'
puts '=' * 30

loop do
  puts "Para conectar a um servidor, digite #{Commands::IN}"
  command = gets.chomp
  next if command != Commands::IN

  print 'Digite o IP do servidor: '
  ip = gets.chomp

  print 'Digite a porta de conexão: '
  port = gets.chomp

  print 'Insira seu nickname: '
  nickname = gets.chomp

  server = TCPSocket.open(ip, port)
  server.puts(nickname)

  should_close = false

  receiver = Thread.new do
    loop do
      break if should_close

      print server.gets
    end
  end

  sender = Thread.new do
    loop do
      break if should_close

      msg = gets.chomp
      case msg
      when Commands::OUT
        server.puts(Commands::OUT)
        should_close = true
      when Commands::LIST_USERS
        server.puts(Commands::LIST_USERS)
      else
        server.puts(msg)
      end
    end
  end

  receiver.join
  sender.join

  server.close
end
