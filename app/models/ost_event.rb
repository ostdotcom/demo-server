class OstEvent < ApplicationRecord

  enum status: {
    GlobalConstant::OstEvents.pending_status => 1,
    GlobalConstant::OstEvents.started_status => 2,
    GlobalConstant::OstEvents.done_status => 3,
    GlobalConstant::OstEvents.failed_status => 4
  }

  serialize :event_data, JSON

  def formatted_cache_data
    {
      id: id,
      event_id: event_id,
      status: status,
      event_data: event_data,
      updated_at: updated_at,
      created_at: created_at
    }
  end

  def update_status(event_id, new_status)
    OstEvent.where(event_id: event_id).update_all(status: new_status)
  end

end
