# frozen_string_literal: true
require 'ruby_jard'

require_relative '../device'
require_relative '../states'

module Devices
  class Lamp < Device
    def initialize
      @state = true
      super
    end

    def send_state
      message = {
        id: @id,
        name: 'Lamp',
        state_kind: States::BOOL,
        state: @state,
        kind: :ACTUATOR
      }

      server_socket.send(message.to_json, 0)
    end

    def alter_state(*)
      @state = !@state

      send_state
    end
  end
end

Devices::Lamp.new.start
