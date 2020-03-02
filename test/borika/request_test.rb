# frozen_string_literal: true

require 'test_helper'

module Borika
  class RequestTest < Minitest::Test
    
    def test_general_request_base64_formatting
      request = Request.new transaction_type: 10,
                            transaction_amount: '99.99',
                            transaction_timestamp: Time.at(0),
                            terminal_id: '12345678',
                            order_id: '12345678',
                            order_summary: 'Money for fun!',
                            signature: FakeSignature.new

      expected_request = "MTAxOTcwMDEwMTAyMDAwMDAwMDAwMDAwOTk5OTEyMzQ1Njc4MTIzNDU2NzggICAgICAgTW9uZXkgZm9yIGZ1biEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBFTjEuMEdHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dH"

      assert_equal expected_request, request.to_s
    end

    def test_protocol_version_validation
      assert_raises ArgumentError do
        Request.new transaction_type: 10,
                    transaction_amount: '99.99',
                    terminal_id: '12345678',
                    order_id: '12345678',
                    order_summary: 'Money for fun!',
                    protocol_version: '3.0',
                    signature: FakeSignature.new
      end
    end

    def test_transaction_type_validation
      assert_raises ArgumentError do
        Request.new transaction_type: 999,
                    transaction_amount: '99.99',
                    terminal_id: '12345678',
                    order_id: '12345678',
                    order_summary: 'Money for fun!',
                    signature: FakeSignature.new
      end
    end

    def test_currency_validation
      assert_raises ArgumentError do
        Request.new transaction_type: 10,
                    transaction_amount: '99.99',
                    terminal_id: '12345678',
                    order_id: '12345678',
                    order_summary: 'Money for fun!',
                    currency: 'KOR',
                    signature: FakeSignature.new
      end
    end

    def test_currency_as_symbols
      Request.new transaction_type: 10,
                  transaction_amount: '99.99',
                  terminal_id: '12345678',
                  order_id: '12345678',
                  order_summary: 'Money for fun!',
                  currency: :eur,
                  signature: FakeSignature.new
    end
  end
end
