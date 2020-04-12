require 'aws-sdk-kms'
require 'base64'

module Utils
  class KMS
    def initialize
      @kms_client = Aws::KMS::Client.new
    end

    def decrypt(ciphertext)
      @kms_client.decrypt(ciphertext_blob: Base64.decode64(ciphertext)).plaintext
    end
  end
end
