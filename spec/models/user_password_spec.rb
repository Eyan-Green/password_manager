# spec/models/user_password_spec.rb

require 'rails_helper'

RSpec.describe UserPassword, type: :model do
  describe 'Associations' do
    it { should belong_to(:password) }
    it { should belong_to(:user) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(UserPassword::ROLES) }
  end
  describe 'Attributes' do
    it 'sets viewer as default value' do
      up = UserPassword.new
      expect(up.role).to eq('Viewer')
    end
  end
  describe 'Permissions' do
    let(:user_password_owner) { UserPassword.new(role: 'Owner') }
    let(:user_password_viewer) { UserPassword.new(role: 'Viewer') }
    let(:user_password_editor) { UserPassword.new(role: 'Editor') }

    it 'checks if user can edit password' do
      expect(user_password_owner.editable?).to eq(true)
      expect(user_password_viewer.editable?).to eq(false)
      expect(user_password_editor.editable?).to eq(true)
    end

    it 'checks if user can share password' do
      expect(user_password_owner.shareable?).to eq(true)
      expect(user_password_viewer.shareable?).to eq(false)
      expect(user_password_editor.shareable?).to eq(false)
    end

    it 'checks if user can destroy password' do
      expect(user_password_owner.destroyable?).to eq(true)
      expect(user_password_viewer.destroyable?).to eq(false)
      expect(user_password_editor.destroyable?).to eq(false)
    end
  end
end
