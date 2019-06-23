# frozen_string_literal: true

RSpec.describe Pragma::Operation do
  before(:all) do
    class CreateUser
      include Pragma::Operation

      step :validate
      step :create

      private

      def validate(input)
        if input[:name].empty?
          Failure(error: 'Name should be filled!')
        else
          Success(input)
        end
      end

      def create(input)
        Success(OpenStruct.new(name: input[:name]))
      end
    end
  end

  it 'can be called' do
    result = CreateUser.new.call(name: 'John Doe')
    expect(result.value!.name).to eq('John Doe')
  end
end
