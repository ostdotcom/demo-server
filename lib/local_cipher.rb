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
      encrypted += (@splitter + iv)

      Result.success({ciphertext_blob: encrypted})
    rescue Exception => e
      Rails.logger.error("Local cipher encrypt error:: #{e.message}")
      return Result.error('l_lc_1', 'INTERNAL_SERVER_ERROR', 'Local cipher encrypt failed')
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
      plaintext = client.update(encrypted_string) + client.final

      Result.success({plaintext: plaintext})
    rescue Exception => e
      Rails.logger.error("Local cipher decrypt error:: #{e.message}")
      return Result.error('l_lc_2', 'INTERNAL_SERVER_ERROR', 'Local cipher decrypt failed')
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