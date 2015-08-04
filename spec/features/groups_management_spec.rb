require 'spec_feature_helper'

feature 'groups management' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'user visits their profile page' do
    it 'shows the Groups link' do
      visit user_path(user)
      expect(page).to have_link('Groups')
    end
  end

  describe 'user clicks the Groups link' do
    before do
      visit user_path(user)
      click_link('Groups')
    end

    it 'shows the Your Groups header' do
      expect(page).to have_content('Your Groups')
    end

    it 'shows the Create Group link' do
      expect(page).to have_link('Create Group')
    end

    describe 'user clicks the Create Group link' do
      it 'shows the new group form'
        #expect(page).to have_field("Group Name")

      context 'when the group info is not valid' do
        it 'shows an error message'

        it 'shows the new group form'
      end

      context 'when the group info is valid' do
        it 'shows a success message'

        it 'shows the group view'
      end
    end
  end
end
