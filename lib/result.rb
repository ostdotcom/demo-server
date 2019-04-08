class Result

  class << self

    def success(data)
      {success: true, data: data}
    end

    def error(internal_id, code, msg)
      {success: false, internal_id: internal_id, code: code, msg: msg}
    end

  end

end