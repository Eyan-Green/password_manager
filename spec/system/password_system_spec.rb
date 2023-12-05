# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password System', type: :system do
  let(:user_instance) { create(:user) }
  let(:user_instance2) { create(:user) }
  let(:user_w_password) { create(:user, :user_password) }

  it 'creates a password, edits it, adds a user and then removes them' do
    login_as user_instance
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

    expect(page).to have_link('Edit')
    click_link 'Edit'
    fill_in 'Username', with: 'Username Updated'
    click_button 'Update Password'
    expect(page).to have_content('Password successfully updated!')
    expect(page).to have_current_path(password_path(Password.last))
    expect(page).to have_content('Username Updated')

    user_instance2
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
    accept_alert 'Are you sure?'
    expect(page).to have_content('User removed from password share!')
    expect(page).to have_current_path(password_path(Password.last))
  end

  it 'redirects to root path when owner is removed from password' do
    login_as user_w_password

    visit passwords_path
    expect(page).to have_link('Username - https://twitter.com')
    click_link 'Username - https://twitter.com'
    expect(page).to have_button('Remove')
    click_button 'Remove'
    accept_alert 'Are you sure?'
    expect(page).to have_content('Record not found!')
    expect(page).to have_current_path(root_path)
  end

  it 'displays error messages when no values are set' do
    login_as user_instance
    visit passwords_path

    expect(page).to have_link('New Password')

    click_link 'New Password'
    expect(page).to have_button('Create Password')
    click_button 'Create Password'
    expect(page).to have_content("Username can't be blank")
    expect(page).to have_content("Url can't be blank")
    expect(page).to have_content("Password can't be blank")
  end
end
