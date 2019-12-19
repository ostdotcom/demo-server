module OstEvents

  # The factory class returns the processor class for the specific ost event.
  class Factory

    # Ost event factory constructor.
    def initialize(request_headers, params, ost_raw_body)
      @request_headers = request_headers
      @event_data = params
      @ost_raw_body = ost_raw_body

      @event_topic = @event_data[:topic]
      @events_processors = {"users/activation_success" => OstEvents::UserActivation,
                            "transactions/initiate" => OstEvents::Transaction::TransactionInitiate,
                            "transactions/success" => OstEvents::Transaction::TransactionSuccess,
                            "transactions/failure" => OstEvents::Transaction::TransactionFailure}
    end

    # Perform action on ost event received. These events are now being processed directly by the service.
    # These events can be processed as a background job in order to reduce load on the main app server.
    def perform
      if @events_processors[@event_topic].present?
        begin
        # Create entry in ost_events table.
        @ost_event_obj = OstEvent.new({
                                        event_id: @event_data[:id],
                                        status: GlobalConstant::OstEvents.pending_status,
                                        event_data: @event_data
                                      })
        @ost_event_obj.save!

        # Call event processor.
        @events_processors[@event_topic].new(@event_data, @request_headers, @ost_raw_body).perform

        rescue ActiveRecord::RecordNotUnique => e
          Rails.logger.info "Error in adding Mysql entry. #{e}"
          Result.success({})
        end
      else
        Result.success({})
      end
    end

  end
end
