class ApiEndpoint < ApplicationRecord

  # Create id to endpoint map
  #
  def self.id_to_endpoint_map
    @id_to_endpoints_map ||= begin
     map = {}
     ApiEndpoint.all.each do |ar_object|
       map[ar_object.id] = ar_object.endpoint
     end
     map
    end
  end

  # Create endpoint to id map
  #
  def self.endpoint_to_id_map
    @endpoint_to_id_map ||= begin
      self.id_to_endpoint_map.invert
    end
  end
end
