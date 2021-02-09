# frozen_string_literal: true

require 'json'
require './multicast_socket'
require './messages'
require './server_socket'

class Gateway
  PORT = 10000
  HOST = 'localhost'

  def initialize
    @connected_devices = []
    @multicast_socket = MulticastSocket.new(only_receive: false)
    @devices_socket = TCPServer.open(HOST, PORT)

    server = ServerSocket.new(devices: @connected_devices)
    search

    t1 = server.listen
    t2 = listen_devices

    t1.join
    t2.join
  end

  def search
    @multicast_socket.send(Messages::SEARCH)
  end

  def listen_devices
    loop do
      Thread.new(@devices_socket.accept) do |client|
        loop do
          message, = client.recv(1000)

          parsed_message = JSON.parse(message, symbolize_names: true)
          device = @connected_devices.find { |dev| dev[:id] == parsed_message[:id] }

          if device.nil?
            parsed_message[:client] = client
            @connected_devices << parsed_message
          else
            device[:state] = parsed_message[:state]
          end
        end
      end
    end
  end
end

Gateway.new
