# frozen_string_literal: true

require 'json'
require './multicast_socket'
require './messages'
require './server_socket'

class Gateway
  def initialize
    @connected_devices = []
    @multicast_socket = MulticastSocket.new(only_receive: false)
    ServerSocket.new(devices: @connected_devices)
    search
    listen_multicast.join
  end

  def search
    @multicast_socket.send(Messages::SEARCH)
  end

  def listen_multicast
    Thread.new do
      loop do
        message, = @multicast_socket.receive
        binding.irb
        next if message == Messages::SEARCH

        parsed_message = JSON.parse(message, symbolize_names: true)
        if parsed_message[:message] == Messages::SEARCH_RESPONSE
          @connected_devices << parsed_message[:name]
        end
      end
    end
  end
end

Gateway.new
