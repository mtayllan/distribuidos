# frozen_string_literal: true

require 'securerandom'
require 'socket'
require './web_message_pb'

PORT = 4567
HOST = 'localhost'

class ServerSocket
  def initialize(devices:)
    @server = TCPServer.open(HOST, PORT)
    @devices = devices
  end

  def listen
    Thread.new(@server.accept) do |client|
      loop do
        msg = client.recv(1000)
        next if msg.nil?

        decoded_message = WebMessage::Request.decode(msg)

        case decoded_message.type
        when :LIST_DEVICES
          response = WebMessage::Response.new

          response.body = @devices.map { |dev| dev[:name] }.join("\n")
          response.type = WebMessage::Response::Type::LIST_DEVICES

          encoded = WebMessage::Response.encode(response)

          client.send(encoded, 0)
        when :REQUIRE_STATUS
          puts 'require status'
        when :ALTER_STATUS
          puts 'alter status'
        else
          puts 'else'
        end
      end
    end
  end
end
