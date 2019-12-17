module OstEvent

  class Factory

    # Ost event factory constructor.
    def initialize(request_headers, params)
      @request_headers = request_headers
      @event_data = params

      @event_topic = params["topic"]
      @events_processors = {"users/activation_success" => OstEvent::UserActivation,
                     "transactions/success" => OstEvent::TransactionComplete}
    end

    # Perform action on ost event received.
    def perform
      if @events_processors[@event_topic].present?
        @events_processors[@event_topic].new(@event_data, @request_headers).perform
      else
        Result.error('a_s_oe_f_1',
                            'INVALID_REQUEST',
                            'Unrecognized event')
      end
    end

  end
end
