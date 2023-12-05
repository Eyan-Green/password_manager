# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:user_passwords) }
    it { should have_many(:passwords).through(:user_passwords) }
  end
end
