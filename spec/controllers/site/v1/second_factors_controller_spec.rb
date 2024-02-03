# frozen_string_literal: true

require 'app_helper'

describe Site::V1::SecondFactorsController do
  def app
    Site::V1::SecondFactorsController
  end

  describe 'GET /site/v1/two_factors/show/:authenticated_code' do
    context 'when the authenticated code is valid' do
      let(:authenticated_code) { 'valid_code' }
      let(:content) { 'Some content' }

      before do
        allow(AuthenticatedUrl).to receive(:get_content).with(authenticated_code).and_return(content)
        AuthenticatedUrl.generate(
          url: '/site/v1/two_factors/show/%<code>s', content:
        )
        get "/site/v1/two_factors/show/#{authenticated_code}"
      end

      it 'returns the content' do
        expect(last_response).to be_ok
        expect(last_response.body).to eq(content)
      end
    end

    context 'when the authenticated code is not found' do
      let(:authenticated_code) { 'invalid_code' }

      before do
        allow(AuthenticatedUrl).to receive(:get_content).with(authenticated_code).and_return('')
        get "/site/v1/two_factors/show/#{authenticated_code}"
      end

      it 'returns "Not found"' do
        expect(last_response).to be_ok
        expect(last_response.body).to eq('Not found')
      end
    end
  end
end
