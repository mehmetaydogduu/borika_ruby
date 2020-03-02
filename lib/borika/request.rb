# frozen_string_literal: true

require 'base64'
module Borika
  
  class Request
    TRANSACTION_TYPES = [
      10, # Authorization
      11, # Payment
      21, # Request delayed authorization
      22, # Execute delayed authorization
      23, # Reverse request delayed authorization
      40, # Reversal
      41  # Reverse payment
    ]

    PROTOCOL_VERSIONS = [
      '1.0',
      '1.1',
      '2.0'
    ]

    CURRENCIES = [
      'USD',
      'EUR',
      'BGN'
    ]

    attr_reader :order_id, :currency, :transaction_amount, :transaction_timestamp, :order_summary,:language
    attr_reader :transaction_type, :one_time_ticket, :terminal_id, :protocol_version, :request_type

    def initialize(
                   order_id:,
                   transaction_amount:,
                   order_summary: 'Order',
                   transaction_timestamp: Time.now,
                   language: 'EN',
                   protocol_version: '1.0',
                   currency: 'EUR',
                   transaction_type: 10,
                   request_type: Borika.config.request_type,
                   terminal_id: Borika.config.borika_terminal_id,
                   one_time_ticket: nil)
      @transaction_type = validate(transaction_type.to_i, of: TRANSACTION_TYPES)
      @transaction_timestamp = transaction_timestamp
      @transaction_amount = validate_cents(transaction_amount).to_s
      @terminal_id = terminal_id
      @order_id = validate_presence(order_id).to_s
      @order_summary = order_summary
      @language = language.to_s.upcase
      @protocol_version = validate(protocol_version.to_s, of: PROTOCOL_VERSIONS)
      @currency = validate(currency.to_s.upcase, of: CURRENCIES)
      @one_time_ticket = one_time_ticket
    end

    def sign_data
      pkeyid = OpenSSL::PKey::RSA.new(Borika.config.private_key, Borika.config.private_key_password)
      signed_str = pkeyid.sign(OpenSSL::Digest::SHA1.new, unsigned_content)
    end

    def url_param
      CGI.escape Base64.strict_encode64(unsigned_content + sign_data(unsigned_content))
    end

    def url
      url = "#{Borika.config.borika_url}#{request_type}?eBorica=#{url_param}"
    end

    private

    def validate(value, of:)
      unless of.include?(value)
        raise ArgumentError, "Expected one of #{of.inspect}, got: #{value.inspect}"
      end
      value
    end

    def validate_cents(value)
      unless value.is_a? Integer || value >= 100
        raise ArgumentError, "Expected integer value with cents, got: #{value.inspect}"
      end
      value
    end

    def validate_presence(value)
      if value.blank?
        raise ArgumentError, "Expected not blank or nil value, got: #{value.inspect}"
      end
      value
    end

    def fill(object, length, char: ' ', right: false)
      truncated = object.to_s[0...length]

      if right
        truncated.rjust(length, char)
      else
        truncated.ljust(length, char)
      end
    end

    def unsigned_content
      @unsigned_content ||= [
        fill(transaction_type, 2),
        fill(transaction_timestamp.strftime('%Y%m%d%H%M%S'), 14),
        fill(transaction_amount, 12, char: '0', right: true),
        fill(terminal_id, 8),
        fill(order_id, 15),
        fill(order_summary, 125),
        fill(language, 2),
        fill(protocol_version, 3),
        (fill(currency, 3) if protocol_version > '1.0'),
        (one_time_ticket if protocol_version == '2.0')
      ].compact.join
    end
  end
end
