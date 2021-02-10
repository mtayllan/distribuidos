# frozen_string_literal: true

require 'socket'
require './web_message_pb'
require 'tty-prompt'
require 'tty-table'
require 'json'

class App
  PORT = 4567
  HOST = 'localhost'

  def initialize
    @server = TCPSocket.open(HOST, PORT)
    @prompt = TTY::Prompt.new
    @device_list = []

    t1 = update_list_loop
    t2 = listen

    receive_commands

    t1.join
    t2.join
  end

  def update_list_loop
    Thread.new do
      loop do
        list_devices
        sleep 1
      end
    end
  end

  def receive_commands
    loop do
      key = @prompt.keypress(timeout: 1) # blocking
      if key.nil?
        output
      else
        request_update_device
      end
    end
  end

  def listen
    Thread.new do
      loop do
        msg = @server.recv(1000)
        next if msg.nil?

        decoded_message = WebMessage::Response.decode(msg)
        @device_list = decoded_message.devices
      end
    end
  end

  def list_devices
    request = WebMessage::Request.new(type: WebMessage::Request::Type::LIST_DEVICES)
    @server.send(WebMessage::Request.encode(request), 0)
  end

  def request_update_device
    id = @prompt.select('Selecione um dispositivo:', @device_list.filter { |dev| dev.kind == :ACTUATOR }.map(&:id))
    selected_device = @device_list.find { |dev| dev.id == id }
    state = selected_device.state_kind != :BOOL ? @prompt.ask('Digite o novo estado:') : ''

    request = WebMessage::Request.new
    request.target_device_id = id
    request.state = state
    request.type = WebMessage::Request::Type::ALTER_STATE

    @server.send(WebMessage::Request.encode(request), 0)
  end

  def output
    if @device_list.size.zero?
      @prompt.say("\e[H\e[2JNenhum dispositivo conectado, buscando...")
    else
      rows = @device_list.map do |device|
        [device.name, device.id, device.state]
      end

      table = TTY::Table.new(%w[Nome ID Estado], rows).render(:unicode, alignments: %i[left left center])
      @prompt.say("\e[H\e[2J#{table}\nPressione qualquer tecla para alterar um dispositivo.")
    end
  end
end

App.new
