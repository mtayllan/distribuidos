# frozen_string_literal: true

require_relative '../device'
require_relative '../states'

module Devices
  class HumiditySensor < Device
    def initialize
      @state = 20
      super
    end

    def send_state
      message = {
        id: @id,
        name: 'HumiditySensor',
        state_kind: States::INT,
        state: @state,
        kind: :SENSOR
      }

      @server_socket.send(message.to_json, 0)
    end

    def alter_state(received_message)
      @state = received_message[:state].to_i

      send_state
    end

    def update_state_loop
      Thread.new do
        loop do
          @state += rand(-2..2)
          send_state
          sleep 3
        end
      end
    end
  end
end

Devices::HumiditySensor.new.start
