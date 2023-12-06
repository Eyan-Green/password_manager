require 'rails_helper'

RSpec.describe PasswordsController, type: :request do
  let(:user_w_password) { create(:user, :user_password) }

  before(:each) do
    login_as user_w_password
  end
  describe 'GET password_path' do
    it 'returns HTTP success' do
      get password_path(user_w_password.passwords.last)
      expect(response).to have_http_status(:success)
    end
    it 'displays a flash message when record is not found' do
      get password_path(user_w_password.passwords.last.id + 1)
      follow_redirect!
      expect(response.body).to include('Record not found!')
    end
  end
  describe 'GET passwords_path' do
    it 'renders index page' do
      get passwords_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Password manager')
      expect(response.body).to include('Add Password')
      expect(response.body).to include(Password.last.url)
    end
  end
  describe 'Create new password' do
    it 'creates new password and displays flash message and URL' do
      get new_password_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('New Password')

      post '/passwords', params: { password: { url: 'https://twitter.com', password: 'Password', username: 'Username' } }
      follow_redirect!
      expect(response.body).to include('Password successfully created!')
      expect(response.body).to include('https://twitter.com')
    end
    it 'returns unprocessable_entity HTTP code and error messages' do
      get new_password_path

      post '/passwords', params: { password: { url: nil, password: nil, username: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Username can&#39;t be blank')
      expect(response.body).to include('Url can&#39;t be blank')
      expect(response.body).to include('Password can&#39;t be blank')
      expect(response.body).to include('New Password')
      expect(response.body).to include('Password could not be created!')
    end
  end
  describe 'Edit and update password' do
    it 'Updates the password and displays a flash message' do
      get edit_password_path(Password.last)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Edit Password')

      patch "/passwords/#{Password.last.id}", params: { password: { url: 'https://apple.com', password: 'Updated', username: 'Username Updated' } }
      follow_redirect!
      expect(response.body).to include('Password successfully updated!')
      expect(response.body).to include('https://apple.com')
    end
    it 'returns unprocessable_entity HTTP code and error messages' do
      get edit_password_path(Password.last)

      patch "/passwords/#{Password.last.id}", params: { password: { url: nil, password: nil, username: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Username can&#39;t be blank')
      expect(response.body).to include('Url can&#39;t be blank')
      expect(response.body).to include('Password can&#39;t be blank')
      expect(response.body).to include('Edit Password')
      expect(response.body).to include('Password could not be updated!')
    end
    it 'does not allow viewer users' do
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      get edit_password_path(Password.last)
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')

      patch "/passwords/#{Password.last.id}", params: { password: { url: 'https://apple.com', password: 'Updated', username: 'Username Updated' } }
      follow_redirect!
      expect(response.body).to include('You don&#39;t have permission to do this!')
    end
  end
  describe 'DELETE destroy' do
    context 'Valid delete' do
      it 'deletes record' do
        password = Password.last
        delete "/passwords/#{password.id}"
        follow_redirect!
        expect(response.body).to include('Password successfully deleted!')
        expect { password.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'removes the association from the user' do
        expect { delete "/passwords/#{Password.last.id}" }.to change { user_w_password.passwords.count }.by(-1)
      end

      it 'does not allow viewer users' do
        user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
        delete "/passwords/#{Password.last.id}"
        follow_redirect!
        expect(response.body).to include('You don&#39;t have permission to do this!')
      end

      it 'does not allow editor users' do
        user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Editor')
        delete "/passwords/#{Password.last.id}"
        follow_redirect!
        expect(response.body).to include('You don&#39;t have permission to do this!')
      end
    end
    context 'Invalid delete' do
      it 'redirects with an alert if deletion fails' do
        allow_any_instance_of(Password).to receive(:destroy).and_return(false)

        delete "/passwords/#{Password.last.id}"

        expect(response).to redirect_to(password_url(Password.last))
        follow_redirect!
        expect(response.body).to include('Failed to delete password!')
      end
    end
  end
end
