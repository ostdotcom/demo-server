class Transaction < ApplicationRecord

  enum status: {
    GlobalConstant::Transactions.pending_status => 1,
    GlobalConstant::Transactions.done_status => 2,
    GlobalConstant::Transactions.failed_status => 3
  }

  serialize :transaction_data, JSON

  def formated_cache_data
    {
      id: id,
      ost_tx_id: ost_tx_id,
      status: status,
      transaction_data: transaction_data,
      updated_at: updated_at,
      created_at: created_at
    }
  end

  def update_status(ost_tx_id, new_status, transaction_data)
    begin
      # Try to update status.
      Transaction.where(ost_tx_id: ost_tx_id).update_all(status: new_status, transaction_data: transaction_data)
    rescue
      # If status update fails, try to create a new entry.
      begin
        transaction_obj = Transaction.new({
                                            ost_tx_id: ost_tx_id,
                                            status: GlobalConstant::Transactions.pending_status,
                                            transaction_data: transaction_data
                                          })

        transaction_obj.save!
      rescue => e
        Rails.logger.error("Transaction creation error:: #{e}")
      end

    end

  end

end
