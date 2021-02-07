# frozen_string_literal: true

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message 'WebMessage.Request' do
    optional :type, :enum, 1, 'WebMessage.Request.Type'
    optional :target_device_id, :int32, 2
  end
  add_enum 'WebMessage.Request.Type' do
    value :REQUIRE_STATUS, 0
    value :ALTER_STATUS, 1
    value :LIST_DEVICES, 2
  end
  add_message 'WebMessage.Response' do
    optional :type, :enum, 1, 'WebMessage.Response.Type'
    optional :target_device_id, :int32, 2
    optional :body, :string, 3
  end
  add_enum 'WebMessage.Response.Type' do
    value :REQUIRE_STATUS, 0
    value :ALTER_STATUS, 1
    value :LIST_DEVICES, 2
  end
end

module WebMessage
  Request = Google::Protobuf::DescriptorPool.generated_pool.lookup('WebMessage.Request').msgclass
  Request::Type = Google::Protobuf::DescriptorPool.generated_pool.lookup('WebMessage.Request.Type').enummodule
  Response = Google::Protobuf::DescriptorPool.generated_pool.lookup('WebMessage.Response').msgclass
  Response::Type = Google::Protobuf::DescriptorPool.generated_pool.lookup('WebMessage.Response.Type').enummodule
end
