class UserTransaction < ApplicationRecord

  def formated_cache_data
    {
      id: id,
      token_user_id: token_user_id,
      ost_tx_id: ost_tx_id,
      updated_at: updated_at,
      created_at: created_at
    }
  end

end
