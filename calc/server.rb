require 'socket'

PORT = 1234
HOST = '0.0.0.0'

socket = UDPSocket.new
socket.bind(HOST, PORT)

loop do
  n1 = socket.recvfrom(10)[0]
  n2 = socket.recvfrom(10)[0]
  op, addr = socket.recvfrom(10)

  n1 = n1.to_f
  n2 = n2.to_f

  case op
  when '+'
    n1 + n2
  when '-'
    n1 - n2
  when '*'
    n1 * n2
  when '/'
    n1 / n2
  end => result

  socket.send(result.to_s, 0, addr[3], addr[1])
end
