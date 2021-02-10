# frozen_string_literal: true

require 'json'
require './multicast_socket'
require './messages'
require 'securerandom'

class Device
  HOST = 'localhost'
  PORT = 10000

  def initialize
    @id = SecureRandom.hex(2)
    @multicast_socket = MulticastSocket.new

    identify
  end

  def start
    t1 = listen_multicast
    t2 = listen_server
    # t3 = update_state_loop

    t1.join
    t2.join
    # t3.join
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

  def server_socket
    @server_socket ||= TCPSocket.open(HOST, PORT)
  rescue
    @server_socket = nil
  end

  def listen_server
    Thread.new do
      loop do
        if server_socket.nil?
          sleep 1
          next
        end

        message = server_socket.recv(1000)

        parsed_message = JSON.parse(message, symbolize_names: true)

        case parsed_message[:kind]
        when Messages::REQUIRE_STATE
          send_state
        when Messages::ALTER_STATE
          alter_state(parsed_message)
        end
      end
    end
  end
end
