class Result

  class << self

    def success(data)
      {success: true, data: data}
    end

    def error(internal_id, code, msg)
      {success: false, internal_id: internal_id, code: code, msg: msg}
    end

    def param_validation_error(internal_id, error_data)
      {success: false, internal_id: internal_id, code: 'INVALID_REQUEST', error_data: error_data,
       msg: 'At least one parameter is invalid or missing. See error_data for more details.'}
    end

  end

end