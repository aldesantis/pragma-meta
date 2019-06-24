# frozen_string_literal: true

module Pragma
  module Resource
    module StepAdapters
      extend Dry::Container::Mixin

      RESERVED_OPTIONS = %i[step_name operation_name].freeze

      register :step, ->(step, options, input) {
        step.operation.call(
          options.delete_if { |k, _| RESERVED_OPTIONS.include?(k) }.merge(input.first),
        )
      }
    end
  end
end
