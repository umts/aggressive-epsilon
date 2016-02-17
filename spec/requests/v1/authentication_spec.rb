require 'rails_helper'

# Request specs don't have token data by default,
# equivalent to being unauthenticated.
describe 'authentication' do
  context 'with improper API token' do
    it 'has an unauthorized status' do
      get '/v1/item_types'
      expect(response).to have_http_status :unauthorized
    end
  end
end
