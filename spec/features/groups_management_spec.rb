require 'spec_feature_helper'

feature 'groups management' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  scenario 'user visits their profile page' do
    visit user_path(user)
    expect(page).to have_link('Groups')
  end
end
