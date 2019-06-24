# frozen_string_literal: true

module Pragma
  module Resource
    module Steps
      class Container
        extend Dry::Container::Mixin

        namespace 'decorator' do
          register 'decorate' do
            Decorator::Decorate.new
          end
        end
      end
    end
  end
end
