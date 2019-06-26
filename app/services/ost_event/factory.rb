module OstEvent
  class Factory

    # Ost Event factory constructor
    def initialize(params)
      ost_event_obj = Oj.parse(params.ostEventObj)

      @event_data = ost_event_obj[:eventData]

      @event_topic = @event_data[:topic]

      @events_processors = {"users/activation_success" => OstEvent::UserActivation,
                     "transactions/success" => OstEvent::TransactionComplete}
    end

    # Perform action on ost event received
    def perform
      if @events_processors[@event_topic].present?
        @events_processors[@event_topic].new(@event_data).perform
      end

      Result.success({})
    end

  end
end