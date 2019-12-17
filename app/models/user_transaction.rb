class UserTransaction < ApplicationRecord

  def formated_cache_data
    {
      id: id,
      token_user_id: token_user_id,
      transaction_id: transaction_id,
      transaction_ts: transaction_ts,
      updated_at: updated_at,
      created_at: created_at
    }
  end

end
