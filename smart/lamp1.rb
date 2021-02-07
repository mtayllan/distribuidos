# frozen_string_literal: true

require 'socket'
require 'ipaddr'

MULTICAST_ADDR = '224.0.1.1'
PORT = 1234

socket = UDPSocket.open

socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)

socket.send('acesa', 0, MULTICAST_ADDR, PORT)
socket.close
