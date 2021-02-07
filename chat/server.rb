require 'socket'
require './commands'

PORT = 4567
HOST = 'localhost'

server = TCPServer.open(HOST, PORT)
connected_clients = []

loop do
  Thread.start(server.accept) do |client|
    nickname = client.gets
    var = { client: client, nickname: nickname }
    connected_clients << var
    connected_clients.each do |c_client|
      c_client[:client].puts("#{nickname} entrou na sala")
    end

    should_close = false
    loop do
      break if should_close

      msg = client.gets.chomp
      case msg
      when Commands::LIST_USERS
        client.puts(connected_clients.map { |c| c[:nickname] }.join("\n"))
      when Commands::OUT
        connected_clients.each do |c_client|
          c_client[:client].puts("#{nickname} saiu da sala")
        end
        connected_clients.delete(var)
        should_close = true
      else
        connected_clients.each do |c_client|
          next if c_client[:nickname] == nickname

          c_client[:client].puts("#{nickname}: #{msg}")
        end
      end
    end
    puts "fechando conexão com #{nickname}"
    client.close
  end
end
