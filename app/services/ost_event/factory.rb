module OstEvent

  class Factory

    # Ost event factory constructor.
    def initialize(request_headers, params)
      @request_headers = request_headers
      @event_data = params

      @event_topic = params["topic"]
      @events_processors = {"users/activation_success" => OstEvent::UserActivation,
                            "transactions/initiate" => OstEvent::TransactionInitiate,
                            "transactions/success" => OstEvent::TransactionSuccess,
                            "transactions/failure" => OstEvent::TransactionFailure}
    end

    # Perform action on ost event received.
    def perform
      if @events_processors[@event_topic].present?
        # Create entry in ost_events table.
        @ost_event_obj = OstEvent.new({
                                        event_id: @event_data.id,
                                        status: GlobalConstant::OstEvents.pending_status,
                                        event_data: @event_data
                                      })
        @ost_event_obj.save!

        # Call event processor.
        @events_processors[@event_topic].new(@event_data, @request_headers).perform
      else
        Result.error('a_s_oe_f_1',
                            'INVALID_REQUEST',
                            'Unrecognized event.')
      end
    end

  end
end
