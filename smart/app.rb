# frozen_string_literal: true

require 'socket'
require './web_message_pb'
require 'tty-prompt'

class App
  PORT = 4567
  HOST = 'localhost'

  def initialize
    @server = TCPSocket.open(HOST, PORT)
    @pause_output = false

    t1 = update_output
    t2 = receive_commands
    t3 = listen

    t1.join
    t2.join
    t3.join
  end

  def update_output
    Thread.new do
      loop do
        next if @pause_output

        list_devices
        sleep 1
      end
    end
  end

  def receive_commands
    Thread.new do
      prompt = TTY::Prompt.new
      loop do
        prompt.keypress()
        @pause_output = true

        id = prompt.ask('Digite o ID do dispositivo')
        state = prompt.ask('Digite o novo estado')

        request = WebMessage::Request.new
        request.target_device_id = id
        request.state = state
        request.type = WebMessage::Request::Type::ALTER_STATE

        @server.send(WebMessage::Request.encode(request), 0)
        @pause_output = false
      end
    end
  end

  def listen
    Thread.new do
      loop do
        msg = @server.recv(1000)
        next if msg.nil?

        decoded_message = WebMessage::Response.decode(msg)

        output(decoded_message.body)
      end
    end
  end

  def list_devices
    request = WebMessage::Request.new(type: WebMessage::Request::Type::LIST_DEVICES)
    @server.send(WebMessage::Request.encode(request), 0)
  end

  def output(msg)
    # quando digitar alguma tecla (Esc, parar o list devices, e abrir o input)
    $stdout.write("\e[H\e[2J#{msg}\nPressione qualquer tecla para alterar um dispositivo.")
  end
end

App.new
