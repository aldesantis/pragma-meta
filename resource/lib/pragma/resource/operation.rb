# frozen_string_literal: true

module Pragma
  module Resource
    module Operation
      def self.included(klass)
        klass.include Dry::Transaction(container: Steps::Container, step_adapters: StepAdapters)
      end

      def model_klass
        [
          root_namespace.join('::'),
          resource_namespace.last
        ].join('::')
      end

      def policy_klass
        [
          resource_namespace,
          'Policy'
        ].join('::')
      end

      def policy_scope_klass
        "#{expected_policy_class}::Scope"
      end

      def instance_decorator_klass
        [
          resource_namespace,
          'Decorator',
          'Instance'
        ].join('::')
      end

      def collection_decorator_klass
        [
          resource_namespace,
          'Decorator',
          'Collection'
        ].join('::')
      end

      def contract_klass
        parts = self.class.name.split('::')

        [
          resource_namespace,
          'Contract',
          parts[(parts.index('Operation') + 1)..-1]
        ].join('::')
      end

      private

      def resource_namespace
        parts = self.class.name.split('::')
        parts[0..(parts.index('Operation') - 1)]
      end

      def root_namespace
        resource_namespace = resource_namespace
        return [] if resource_namespace.first.casecmp('API').zero?

        api_index = (resource_namespace.map(&:upcase).index('API') || 1)
        resource_namespace[0..(api_index - 1)]
      end

      def load_klass(klass)
        # FIXME: This entire block is required to trigger Rails autoloading. Ugh.
        begin
          Object.const_get(klass)
        rescue NameError => e
          # We check the error message to avoid silently ignoring other NameErrors
          # thrown while initializing the constant.
          raise e unless e.message.start_with?('uninitialized constant')

          # Required instead of a simple equality check because loading
          # API::V1::Post::Contract::Index might throw "uninitialized constant
          # API::V1::Post::Contract" if the resource has no contracts at all.
          error_constant = e.message.scan(/uninitialized constant ([^\s]+)/).first.first
          raise e unless klass.sub(/\A::/, '').start_with?(error_constant)
        end

        Object.const_get(klass) if Object.const_defined?(klass)
      end
    end
  end
end
