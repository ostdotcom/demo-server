class LocalCipher

  # Local Cipher constructor
  #
  def initialize(key)
    @key = key
    @splitter = '--'
  end

  # Encrypt plain text
  #
  def encrypt(plaintext)
    begin
      iv = generate_random_iv
      client.encrypt
      client.key = @key
      client.iv = iv

      encrypted = ''
      encrypted << client.update(plaintext)
      encrypted << client.final
      encrypted_string = Base64.encode64(encrypted).gsub(/\n/, '')
      encrypted_string += (@splitter + iv)

      Result.success({ciphertext_blob: encrypted_string})
    rescue => e
      Rails.logger.error("Local cipher encrypt error:: #{e.message}")
      return Result.error('l_lc_1', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
    end
  end

  # Decrypt plain text
  #
  def decrypt(ciphertext_blob)
    begin

      arr = ciphertext_blob.split(@splitter)
      encrypted_string = arr[0]
      iv = arr[1]

      client.decrypt
      client.key = @key
      client.iv = iv
      encrypted_string = Base64.urlsafe_decode64(encrypted_string)
      plaintext = client.update(encrypted_string) + client.final

      Result.success({plaintext: plaintext})
    rescue => e
      Rails.logger.error("Local cipher decrypt error:: #{e.message}")
      return Result.error('l_lc_2', 'SERVICE_UNAVAILABLE', 'Service Temporarily Unavailable')
    end
  end

  private

  def client
    @client ||= OpenSSL::Cipher.new('aes-256-cbc')
  end

  def generate_random_iv
    SecureRandom.hex(8)
  end

end