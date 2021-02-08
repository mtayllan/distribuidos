# frozen_string_literal: true

require 'socket'
require './web_message_pb'

class App
  PORT = 4567
  HOST = 'localhost'

  def initialize
    @server = TCPSocket.open(HOST, PORT)

    t1 = prompt
    t2 = listen
    list_devices

    t1.join
    t2.join
  end

  def prompt
    Thread.new do
      list_devices
      loop do
        puts 'O que você deseja fazer?'
        puts "
          1 - Listar dispositivos\n
          2 - Alterar dispositivo\n
          3 - Ver status de um dispositivo
        "
        option = gets.chomp

        case option.to_i
        when 1
          list_devices
        when 2
          puts 'alterar'
        when 3
          puts 'ver status'
        else
          puts 'Invalido fodac'
        end
      end
    end
  end

  def listen
    Thread.new do
      loop do
        msg = @server.recv(1000)
        next if msg.nil?

        decoded_message = WebMessage::Response.decode(msg)

        case decoded_message.type
        when :LIST_DEVICES
          puts decoded_message.body
        when :ALTER_STATUS
          puts msg.body
        when :REQUIRE_STATUS
          puts msg.body
        end
      end
    end
  end

  def list_devices
    request = WebMessage::Request.new(type: WebMessage::Request::Type::LIST_DEVICES)
    @server.send(WebMessage::Request.encode(request), 0)
  end
end

App.new
