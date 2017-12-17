RSpec.describe Pragma::Operation::Macro::Policy do
  subject(:result) do
    PolicyMacroTest::Operation.(params, options)
  end

  let(:options) { { 'current_user' => current_user } }
  let(:params) { {} }

  before do
    module PolicyMacroTest
      class Policy
        def initialize(user, model)
          @user = user
          @model = model
        end

        def operation?
          @user.id == @model.user_id
        end
      end

      class Operation < Pragma::Operation::Base
        self['policy.default.class'] = Policy

        step :model!
        step Pragma::Operation::Macro::Policy(), fail_fast: true
        step :finish!

        def model!(options)
          options['model'] = OpenStruct.new(user_id: 1)
        end

        def finish!(options)
          options['result.finished'] = true
        end
      end
    end
  end

  context 'when the user is authorized' do
    let(:current_user) { OpenStruct.new(id: 1) }

    it 'lets the operation continue' do
      expect(result['result.finished']).to be true
    end
  end

  context 'when the user is unauthorized' do
    let(:current_user) { OpenStruct.new(id: 2) }

    it 'stops the operation' do
      expect(result['result.finished']).not_to be true
    end

    it 'responds with 403 Forbidden' do
      expect(result['result.response'].status).to eq(403)
    end
  end
end
