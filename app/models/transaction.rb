class Transaction < ApplicationRecord

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

end
