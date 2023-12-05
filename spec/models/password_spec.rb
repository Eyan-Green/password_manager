# spec/models/password_spec.rb

require 'rails_helper'

RSpec.describe Password, type: :model do
  let(:user_w_password) { create(:user, :user_password) }
  describe 'associations' do
    it { should have_many(:user_passwords) }
    it { should have_many(:users).through(:user_passwords) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:password) }
  end
  describe 'Methods' do
    it 'returns true' do
      password = user_w_password.passwords.last
      expect(password.editable_by?(user_w_password)).to be true
    end
    it 'returns true' do
      password = user_w_password.passwords.last
      expect(password.shareable_by?(user_w_password)).to be true
    end
    it 'returns true' do
      password = user_w_password.passwords.last
      expect(password.destroyable_by?(user_w_password)).to be true
    end
    it 'returns false' do
      password = user_w_password.passwords.last
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      expect(password.editable_by?(user_w_password)).to be false
    end
    it 'returns false' do
      password = user_w_password.passwords.last
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      expect(password.shareable_by?(user_w_password)).to be false
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Editor')
      expect(password.shareable_by?(user_w_password)).to be false
    end
    it 'returns false' do
      password = user_w_password.passwords.last
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Viewer')
      expect(password.destroyable_by?(user_w_password)).to be false
      user_w_password.user_passwords.find_by(user: user_w_password).update(role: 'Editor')
      expect(password.destroyable_by?(user_w_password)).to be false
    end
    it 'returns users not associated with password and does not return those that are' do
      password = user_w_password.passwords.last
      user = create(:user)
      expect(password.shareable_users).to_not include(user_w_password)
      expect(password.shareable_users).to include(user)
    end
  end
end
