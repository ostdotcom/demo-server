class Kms

  # Initialize
  #
  def initialize
  end

  # Decrypt
  #
  def decrypt(ciphertext_blob)
    begin
      d_resp = client.decrypt({ciphertext_blob: ciphertext_blob}).to_h
      plaintext = d_resp[:plaintext]
      return Result.success({plaintext: plaintext})
    rescue => e
      Rails.logger.error("KMS Decrypt error:: #{e.message}")
      return Result.error('l_k_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
    end
  end

  # Encrypt
  #
  def encrypt(plaintext)
    begin
      e_resp = client.encrypt({plaintext: plaintext, key_id: key_id}).to_h
      ciphertext_blob = e_resp[:ciphertext_blob]
      return Result.success({ciphertext_blob: ciphertext_blob})
    rescue => e
      Rails.logger.error("KMS Encrypt error:: #{e.message}")
      return Result.error('l_k_2', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
    end
  end

  # Generate data key
  #
  def generate_data_key
    begin
      resp = client.generate_data_key({key_id: key_id, key_spec: "AES_256"})
      return Result.success({ciphertext_blob: resp.ciphertext_blob, plaintext: resp.plaintext})
    rescue => e
      Rails.logger.error("KMS Generate error:: #{e.message}")
      return Result.error('l_k_3', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
    end
  end

  private

  # Client
  #
  def client
    @client ||= Aws::KMS::Client.new(access_key_id: access_key, secret_access_key: secret, region: region)
  end

  # Key id
  #
  def key_id
    GlobalConstant::Kms.key_id
  end

  # Access key
  #
  def access_key
    GlobalConstant::Kms.access_key
  end

  # Secret
  #
  def secret
    GlobalConstant::Kms.secret
  end

  # Region
  #
  def region
    GlobalConstant::Kms.region
  end

end