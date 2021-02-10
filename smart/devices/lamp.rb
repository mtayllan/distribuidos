# frozen_string_literal: true

require_relative '../device'
require_relative '../states'

module Devices
  class Lamp < Device
    def initialize
      @state = true
      super
    end

    def identify
      return if server_socket.nil?

      send_state
    end

    def send_state
      message = {
        id: @id,
        name: 'Lamp',
        state_kind: States::BOOL,
        state: @state,
        kind: :ACTUATOR
      }

      @server_socket.send(message.to_json, 0)
    end

    def alter_state
      @state = !@state

      send_state
    end

    def update_state_loop
      Thread.new do
        loop do
          @state = !@state

          send_state

          sleep 3
        end
      end
    end
  end
end

Devices::Lamp.new.start
