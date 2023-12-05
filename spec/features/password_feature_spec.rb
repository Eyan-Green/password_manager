# frozen_string_literal: true

require 'rails_helper'

feature 'User visits passwords path' do
  include ActionView::RecordIdentifier
  let(:user_w_password) { create(:user, :user_password) }
  let(:user_instance2) { create(:user) }

  before(:each) { login_as user_w_password }

  scenario 'They create a new password' do
    visit passwords_path

    expect(page).to have_link('New Password')

    click_link 'New Password'

    expect(page).to have_content('New Password')
    expect(page).to have_field('password_url')
    expect(page).to have_field('password_username')
    expect(page).to have_field('password_password')

    fill_in 'Url', with: 'https://twitter.com'
    fill_in 'Username', with: 'Username'
    fill_in 'Password', with: 'Password'
    click_button 'Create Password'

    expect(page).to have_content('Password successfully created!')
    expect(page).to have_current_path(password_path(Password.last))
  end

  scenario 'They see the instance and values and edit password' do
    password = user_w_password.passwords.last
    visit password_path(password)

    expect(page).to have_content(password.url)
    expect(page).to have_content(password.password)
    expect(page).to have_content(password.username)
    expect(page).to have_content('Credentials')
    expect(page).to have_content('Username / Email')
    expect(page).to have_content('Copy')
    expect(page).to have_content('Password')
    expect(page).to have_content('Shared with')
    expect(page).to have_link('Edit')
    click_link 'Edit'
    expect(page).to have_field('Url')
    expect(page).to have_field('Username')
    expect(page).to have_field('Password')
    fill_in 'Username', with: 'Username Updated'
    expect(page).to have_button('Update Password')
    click_button 'Update Password'
    expect(page).to have_content('Username Updated')
    expect(page).to have_current_path(password_path(password))
  end

  scenario 'They add a new user to the password and then remove them' do
    password = user_w_password.passwords.last
    user_instance2
    visit password_path(password)
    expect(page).to have_link('Add a user')
    click_link 'Add a user'
    expect(page).to have_selector('#user_password_user_id')
    expect(page).to have_selector('#user_password_role')
    expect(page).to have_button('Share')
    click_button 'Share'
    expect(page).to have_content('Password shared with user!')
    expect(page).to have_current_path(password_path(Password.last))

    last_remove_button = page.all('button', text: 'Remove').last
    last_remove_button.click
    expect(page).to have_content('User removed from password share!')
    expect(page).to have_current_path(password_path(Password.last))
  end
end
