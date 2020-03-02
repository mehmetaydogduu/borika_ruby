# frozen_string_literal: true

require 'borika/version'
require 'borika/request'
require 'ostruct'

module Borika
  def self.config
    @config ||= OpenStruct.new
  end
  
  def self.configure
    yield(config)
  end
end

# Borika.config # => #<OpenStruct foo="bar">
# Borika.config.foo #=> "bar"