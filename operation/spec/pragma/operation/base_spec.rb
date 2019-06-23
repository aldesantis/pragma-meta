# frozen_string_literal: true

RSpec.describe Pragma::Operation::Base do
  subject(:result) do
    operation_klass.call(*args)
  end

  let(:operation_klass) do
    Class.new(described_class) do
      step :process!

      def process!(options, params:, current_user_id:)
        params[:foo] == 'bar' && current_user_id == 1
      end
    end
  end

  context 'with TRB 0.5.1 signature' do
    let(:args) do
      [
        {
          params: { foo: 'bar' },
          current_user_id: 1
        },
      ]
    end

    it 'runs correctly' do
      expect(result).to be_success
    end
  end

  context 'with TRB 0.4.1 signature' do
    let(:args) do
      [
        { foo: 'bar' },
        { 'current_user_id' => 1 },
      ]
    end

    it 'runs correctly' do
      expect(result).to be_success
    end
  end
end
