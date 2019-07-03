module OstEvent
  class Factory

    # Ost Event factory constructor
    def initialize(request_headers, params)
      @event_data = params["data"]

      @event_topic = params["topic"]

      @events_processors = {"users/activation_success" => OstEvent::UserActivation,
                     "transactions/success" => OstEvent::TransactionComplete}

      @request_headers = request_headers
    end

    # Perform action on ost event received
    def perform
      if @events_processors[@event_topic].present?
        @events_processors[@event_topic].new(@event_data, @request_headers).perform
      else
        return Result.error('a_s_oe_f_1',
                            'INVALID_REQUEST',
                            'Unrecognized event')
      end

      Result.success({})
    end

  end
end