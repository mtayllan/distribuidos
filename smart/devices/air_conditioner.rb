# frozen_string_literal: true

require_relative '../device'
require_relative '../states'

module Devices
  class AirConditioner < Device
    def initialize
      @state = 24
      super
    end

    def identify
      return if server_socket.nil?

      send_state
    end

    def send_state
      message = {
        id: @id,
        name: 'AirConditioner',
        state_kind: States::INT,
        state: @state
      }

      @server_socket.send(message.to_json, 0)
    end

    def alter_state(received_message)
      @state = received_message[:state]

      send_state
    end

    def update_state_loop
      Thread.new do
        loop do
          @state += 1
          send_state
          sleep 3
        end
      end
    end
  end
end

Devices::AirConditioner.new.start
