# frozen_string_literal: true
require 'base64'
require 'openssl'
module Borika
  class InvalidSignatureError < ::StandardError; end
  class InvalidResponseSizeError < ::StandardError; end
  class Response
    def initialize(response)
      str = Base64.decode64 response
      unless str.bytesize == 128
        InvalidResponseSizeError.new "Borica Response has invalid size"
      end
      signed_str = str.byteslice(56,128)
      pkeyid = OpenSSL::PKey::RSA.new(Borika.config.private_key, Borika.config.private_key_password)
      unless pkeyid.verify(OpenSSL::Digest::SHA1.new, signed_str, str)
        raise InvalidSignatureError.new "Borica Response RSA SHA1 Sign Verification failed"
      end
      # get data
      hash = {
        :order_id => str.byteslice(36,15),
        :status => str.byteslice(51,2) == '00' ? :success : :failed
        :transaction_code => str.byteslice(0,2),
        :transaction_time => str.byteslice(2,14),
        :amount => str.byteslice(16,12),
        :terminal_id => str.byteslice(28,8),
        :error_code => str.byteslice(51,2),
        :protocol_version => str.byteslice(53,3),
        :original_response => response
      }
    end
  end
end