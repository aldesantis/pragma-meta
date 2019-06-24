# frozen_string_literal: true

module Pragma
  module Operation
    # Finds the requested record, authorizes it and decorates it.
    class Show < Pragma::Operation::Base
      step Macro::Classes()
      step Macro::Model(:find_by)
      step Macro::Policy()
      step Macro::Decorator()
      step :respond!, name: 'respond'

      def respond!(options)
        options['result.response'] = Response::Ok.new(entity: options['result.decorator.instance'])
      end
    end
  end
end

module Pragma
  module Operation
    Show = Pragma::Resource::Show
  end
end
