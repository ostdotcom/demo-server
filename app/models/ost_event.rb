class OstEvent < ApplicationRecord

  enum status: {
    GlobalConstant::OstEvents.pending_status => 1,
    GlobalConstant::OstEvents.started_status => 2,
    GlobalConstant::OstEvents.done_status => 3,
    GlobalConstant::OstEvents.failed_status => 4
  }

  serialize :event_data, JSON

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
