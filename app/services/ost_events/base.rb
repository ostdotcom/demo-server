module OstEvents

  class Base

    def initialize(event_data, request_headers)
      @event_data = event_data
      @request_headers = request_headers
    end

    def mark_ost_event_started
      OstEvent.new.update_status(@event_data[:id], GlobalConstant::OstEvents.started_status)
    end

    def mark_ost_event_done
      OstEvent.new.update_status(@event_data[:id], GlobalConstant::OstEvents.done_status)
    end

    def mark_ost_event_failed
      OstEvent.new.update_status(@event_data[:id], GlobalConstant::OstEvents.failed_status)
    end

  end
end
