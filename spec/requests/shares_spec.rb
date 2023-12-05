require 'rails_helper'

RSpec.describe SharesController, type: :request do
  let(:user_w_password) { create(:user, :user_password) }
  let(:user_instance) { create(:user) }

  before(:each) { login_as user_w_password }

  describe 'GET new > POST create' do
    it 'shares password with a new user' do
      password = Password.last
      get "/passwords/#{password.id}/shares/new"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Share password')

      post "/passwords/#{password.id}/shares", params: { user_password: { user_id: user_instance.id, role: 'Owner' } }
      follow_redirect!
      expect(response.body).to include('Password shared with user!')
    end

    it "doesn't allow viewer users" do
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      get "/passwords/#{Password.last.id}/shares/new"
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')
    end

    it "doesn't allow editor users" do
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Editor')
      get "/passwords/#{Password.last.id}/shares/new"
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')
    end

    it 'returns unprocessable_entity' do
      password = Password.last
      get "/passwords/#{password.id}/shares/new"

      post "/passwords/#{password.id}/shares", params: { user_password: { user_id: user_instance.id, role: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE destroy' do
    it 'removes user from password' do
      password = Password.last
      post "/passwords/#{password.id}/shares", params: { user_password: { user_id: user_instance.id } }
      delete "/passwords/#{password.id}/shares/#{user_instance.id}"
      follow_redirect!
      expect(response.body).to include('User removed from password share!')
      expect(password.users).to_not include(user_instance)
    end

    it "doesn't allow viewer users" do
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      password = Password.last
      post "/passwords/#{password.id}/shares", params: { user_password: { user_id: user_instance.id } }
      delete "/passwords/#{password.id}/shares/#{user_instance.id}"
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')
    end

    it "doesn't allow editor users" do
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Editor')
      password = Password.last
      post "/passwords/#{password.id}/shares", params: { user_password: { user_id: user_instance.id } }
      delete "/passwords/#{password.id}/shares/#{user_instance.id}"
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')
    end
  end
end
