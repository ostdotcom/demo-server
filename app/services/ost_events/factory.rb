module OstEvents

  class Factory

    # Ost event factory constructor.
    def initialize(request_headers, params, ost_raw_body)
      @request_headers = request_headers
      @event_data = Oj.load(params)
      @ost_raw_body = ost_raw_body
      Rails.logger.info "=====params==1111=#{params}"
      Rails.logger.info "=====ost_raw_body===2222222=#{ost_raw_body}"

      @event_topic = @event_data[:topic]
      @events_processors = {"users/activation_success" => OstEvents::UserActivation,
                            "transactions/initiate" => OstEvents::Transaction::TransactionInitiate,
                            "transactions/success" => OstEvents::Transaction::TransactionSuccess,
                            "transactions/failure" => OstEvents::Transaction::TransactionFailure}
    end

    # Perform action on ost event received.
    def perform
      if @events_processors[@event_topic].present?
        # Create entry in ost_events table.
        @ost_event_obj = OstEvent.new({
                                        event_id: @event_data[:id],
                                        status: GlobalConstant::OstEvents.pending_status,
                                        event_data: @event_data
                                      })
        @ost_event_obj.save!

        # Call event processor.
        @events_processors[@event_topic].new(@event_data, @request_headers, @ost_raw_body).perform
      else
        Result.error('a_s_oe_f_1',
                            'INVALID_REQUEST',
                            'Unrecognized event.')
      end
    end

  end
end
