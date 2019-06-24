# frozen_string_literal: true

module Pragma
  module Resource
    # Creates a new record and responds with the decorated record.
    class Create < Pragma::Operation::Base
      include Pragma::Resource::Operation

      step :decorate, with: 'decorator.decorate', foo: 'bar'
    end
  end
end
