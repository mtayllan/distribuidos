# frozen_string_literal: true

require_relative '../device'
require_relative '../states'

module Devices
  class HumiditySensor < Device
    def initialize
      @state = 50
      super
    end

    def identify
      return if server_socket.nil?

      send_state
    end

    def send_state
      message = {
        id: @id,
        name: 'HumiditySensor',
        state_kind: States::INT,
        state: @state
      }

      @server_socket.send(message.to_json, 0)
    end

    def alter_state(received_message)
      @state = received_message[:state]

      send_state
    end
  end
end

Devices::HumiditySensor.new.start
