class OstEventsTransactionsBase < OstEventsBase

  def initialize(event_data, request_headers)
    super

    @transaction_data = event_data["data"]["transaction"]
  end

  def create_entry_in_transactions

    @transaction_obj = Transaction.new({
      ost_tx_id: @transaction_data.id,
      status: GlobalConstant::Transactions.pending_status,
      transaction_data: @transaction_data
                    })

    @transaction_obj.save!

  end

  def mark_transaction_done
    Transaction.new.update_status(@transaction_data.id, GlobalConstant::Transactions.done_status)
  end

  def mark_transaction_failed
    Transaction.new.update_status(@transaction_data.id, GlobalConstant::Transactions.failed_status)
  end

end
