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

        it 'shows a list of admin members' do
          expect(page).to have_content('Admin Members')
        end

        it 'shows the user as an admin' do
          within('ul#admin_members') do
            expect(page).to have_content(user.username)
          end
        end

        it 'shows an add member button' do
          expect(page).to have_link('Add Group Member')
        end

        context 'adding a member' do
          let!(:existing_user) { create(:user) }

          before do
            expect(User.all).to include(existing_user)
            click_link('Add Group Member')
          end

          it 'shows the new member form' do
            expect(page).to have_content("Add Group Members")
          end

          context 'when the create is successful' do
            before do
              find(:xpath, "//input[@id='user_id']").set "#{existing_user.id}"
              click_button('Add Member')
            end

            it 'shows a success message' do
              expect(page).to have_content('Member successfully added!')
            end

            it 'shows a list of members' do
              within('ul#members') do
                expect(page).to have_content(existing_user.username)
              end
            end

            it 'shows a remove button' do
              within('ul#members') do
                expect(page).to have_link('Remove')
              end
            end

            it 'shows a \'Make Admin\' button' do
              within('ul#members') do
                expect(page).to have_link('Make Admin')
              end
            end

            context 'making a member an admin' do
              before do
                within('ul#members') do
                  click_link('Make Admin')
                end
              end

              it 'shows the member as an admin' do
                within('ul#admin_members') do
                  expect(page).to have_content(user.username)
                end
              end
            end

            context 'removing a member' do
              before do
                within('ul#members') do
                  click_link('Remove')
                end
              end

              it 'shows a success message' do
                expect(page).to have_content('Member successfully removed')
              end

              it 'does not contain the removed member' do
                within('ul#members') do
                  expect(page).to_not have_content(existing_user.username)
                end
              end
            end
          end
        end

        context 'showing the group on the user\'s groups profile page' do
          before do
            expect(page).to have_link('View Profile')
            click_link('View Profile')
            click_link('Groups')
          end

          it 'shows the group' do
            expect(page).to have_link(Group.last.name)
          end

          it 'links to the group show page' do
            click_link(Group.last.name)
            expect(page).to have_content(Group.name)
          end
        end
      end
    end
  end
end
