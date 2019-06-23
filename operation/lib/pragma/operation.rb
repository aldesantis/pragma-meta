# frozen_string_literal: true

require 'dry-transaction'
require 'json'
require 'zeitwerk'

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.setup
  loader.eager_load
end

module Pragma
  module Operation
    def self.included(klass)
      klass.include Dry::Transaction
    end
  end
end
