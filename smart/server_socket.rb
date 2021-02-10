# frozen_string_literal: true

require 'securerandom'
require 'socket'
require './web_message_pb'
require './messages'

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
          @devices.each do |device|
            device[:client].send({ kind: Messages::REQUIRE_STATE }.to_json, 0)
          end
          send_devices_state(client)
        when :ALTER_STATE
          device_id = decoded_message.target_device_id
          device = @devices.find { |dev| dev[:id] == device_id }
          # checar tipos
          device[:client].send({ kind: Messages::ALTER_STATE, state: decoded_message.state }.to_json, 0)
        end
      end
    end
  end

  def send_devices_state(client)
    response = WebMessage::Response.new

    @devices.each do |device|
      response.devices << WebMessage::Response::Device.new(
        id: device[:id],
        state: device[:state].to_s,
        name: device[:name],
        state_kind: device[:state_kind],
        kind: device[:kind]
      )
    end

    encoded = WebMessage::Response.encode(response)

    client.send(encoded, 0)
  end
end
