require 'rails_helper'

RSpec.describe PublicController, type: :controller do
  render_views

  describe 'GET #status' do
    before do
      sign_in create(:user)
    end

    it 'returns http success' do
      get :status
      expect(response).to be_successful
    end

    it 'returns migration, commit and request ip' do
      request.env['REMOTE_ADDR'] = '1.2.3.4'
      current_commit = `git show --pretty=%H -q`.chomp
      current_migration = ActiveRecord::SchemaMigration.last.version.to_s

      get :status

      expect(response.body.include?(current_commit)).to eq(true)
      expect(response.body.include?(current_migration)).to eq(true)
      expect(response.body.include?('1.2.3.4')).to eq(true)
    end
  end
end
