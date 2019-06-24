# frozen_string_literal: true

RSpec.describe Pragma::Operation::Base do
  before(:all) do
    class CreateUser < Pragma::Operation::Base
      step :validate
      step :normalize
      step :create

      private

      def validate(input)
        if input[:name].empty?
          Failure(error: 'Name must be present!')
        else
          Success(input)
        end
      end

      def normalize(input)
        Success(name: input[:name].split(' ').map(&:capitalize).join(' '))
      end

      def create(input)
        Success(input)
      end
    end
  end

  it 'handles success cases' do
    result = CreateUser.new.call(name: 'john doe')
    expect(result.value!).to eq(name: 'John Doe')
  end

  it 'handles failure cases' do
    result = CreateUser.new.call(name: '')
    expect(result.failure).to eq(error: 'Name must be present!')
  end
end
