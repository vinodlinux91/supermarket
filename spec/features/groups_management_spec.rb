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
      expect(page).to have_content("#{user.name}'s Groups")
    end

    it 'shows the Create Group link' do
      expect(page).to have_link('Create Group')
    end

    describe 'user clicks the Create Group link' do
      before do
        click_link('Create Group')
      end

      it 'shows the new group form' do
        expect(page).to have_field('Group Name')
      end

      it 'shows a Create Group link' do
        expect(page).to have_button('Create Group')
      end

      context 'when the create is not successful' do
        before do
          fill_in('Group Name', with: '')
          click_button('Create Group')
        end

        it 'shows an error message' do
          expect(page).to have_content('An error has occurred')
        end

        it 'shows the new group form' do
          expect(page).to have_field('Group Name')
        end
      end

      context 'when the create is successful' do
        before do
          fill_in('Group Name', with: 'My Next Group')
          click_button('Create Group')
        end

        it 'shows a success message' do
          expect(page).to have_content('Group successfully created!')
        end

        it 'shows the group' do
          expect(page).to have_content('My Next Group')
        end

        it 'shows a list of members' do
          expect(page).to have_content('Members')
        end

        it 'shows the user as a member' do
          expect(page).to have_content(user.username)
          expect(page).to have_content(user.first_name)
          expect(page).to have_content(user.last_name)
        end
      end
    end
  end
end
