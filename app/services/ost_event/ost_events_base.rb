class OstEventsBase

  def initialize(event_data, request_headers)
    @event_data = event_data
    @request_headers = request_headers
  end

  def create_entry_in_ost_events
    @ost_event_obj = OstEvent.new({
                    event_id: @event_data.id,
                    status: GlobalConstant::OstEvents.pending_status,
                    event_data: @event_data
                 })
    @ost_event_obj.save!
  end

end
