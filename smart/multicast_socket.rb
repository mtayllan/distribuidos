# frozen_string_literal: true

require 'socket'
require 'ipaddr'

class MulticastSocket
  MULTICAST_ADDR = '224.0.1.1'
  BIND_ADDR = '0.0.0.0'
  PORT = 1234
  ENABLED = 1
  MEMBERSHIP = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton

  attr_reader :socket

  def initialize(only_receive: true)
    @socket = UDPSocket.open.tap do |socket|
      socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1) unless only_receive
      socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, MEMBERSHIP)
      socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, ENABLED)

      socket.bind(BIND_ADDR, PORT)
    end
  end

  def send(msg)
    @socket.send(msg, 0, MULTICAST_ADDR, PORT)
  end

  def receive
    @socket.recvfrom(1024)
  end
end
