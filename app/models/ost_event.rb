class OstEvent < ApplicationRecord

  def formated_cache_data
    {
      id: id,
      event_id: event_id,
      status: status,
      event_data: event_data,
      updated_at: updated_at,
      created_at: created_at
    }
  end

end
