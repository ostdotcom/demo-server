class UserTransaction < ApplicationRecord

  def formated_cache_data
    {
      id: id,
      user_id: user_id,
      ost_tx_id: ost_tx_id,
      updated_at: updated_at,
      created_at: created_at
    }
  end

end
