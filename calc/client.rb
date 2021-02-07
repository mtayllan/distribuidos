require 'socket'

PORT = 1234
HOST = '0.0.0.0'

socket = UDPSocket.new
socket.connect(HOST, PORT)

puts 'Bem-vindo a calculadora'
puts '=' * 20
loop do
  print 'Digite o primeiro número: '
  n1 = gets.chomp

  print 'Digite o segundo número: '
  n2 = gets.chomp

  print 'Digite a operação: '
  op = gets.chomp

  socket.send(n1, 0)
  socket.send(n2, 0)
  socket.send(op, 0)

  print 'Resultado: '
  puts socket.recv(10)
  puts '=' * 20
end
