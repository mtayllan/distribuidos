# frozen_string_literal: true

require 'json'
require './multicast_socket'
require './messages'

class Lamp
  SERVER_HOST = '0.0.0.0'
  SERVER_PORT = 6969

  def initialize
    @multicast_socket = MulticastSocket.new

    identify
    listen_multicast.join
  end

  def listen_multicast
    Thread.new do
      loop do
        message, = @multicast_socket.receive
        if message == Messages::SEARCH
          identify
        end
      end
    end
  end

  def identify
    @multicast_socket.send({ name: 'Lamp2', port: SERVER_PORT, message: Messages::SEARCH_RESPONSE }.to_json)
  end
end

Lamp.new
