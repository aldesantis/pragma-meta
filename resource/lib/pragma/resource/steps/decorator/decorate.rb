# frozen_string_literal: true

require 'dry/transaction/operation'

module Pragma
  module Resource
    module Steps
      module Decorator
        class Decorate
          include Dry::Transaction::Operation

          def call(*args)
            Success(*args)
          end
        end
      end
    end
  end
end
