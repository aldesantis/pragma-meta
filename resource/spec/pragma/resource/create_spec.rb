# frozen_string_literal: true

RSpec.describe Pragma::Resource::Create do
  subject(:result) do
    described_class.new.call(params: params, current_user: current_user)
  end

  let(:params) do
    { title: 'My New Post' }
  end

  let(:current_user) { OpenStruct.new(id: 1) }

  it 'responds with 201 Created' do
    expect(result['result.response'].status).to eq(201)
  end

  it 'responds with the decorated resource' do
    expect(result['result.response'].entity).to be_kind_of(Pragma::Decorator::Base)
  end

  context 'when validation fails' do
    let(:params) do
      { title: '' }
    end

    it 'responds with 422 Unprocessable Entity' do
      expect(result['result.response'].status).to eq(422)
    end

    it 'decorates the error' do
      expect(result['result.response'].entity).to be_kind_of(Pragma::Decorator::Error)
    end
  end

  context 'when the user is not authorized' do
    let(:current_user) { OpenStruct.new(id: 2) }

    it 'responds with 403 Forbidden' do
      expect(result['result.response'].status).to eq(403)
    end

    it 'decorates the error' do
      expect(result['result.response'].entity).to be_kind_of(Pragma::Decorator::Error)
    end
  end
end
