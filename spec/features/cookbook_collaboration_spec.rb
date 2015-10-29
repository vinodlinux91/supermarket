require 'spec_feature_helper'

describe 'cookbook collaboration' do
  let(:suzie) { create(:user) }
  let(:sally) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }

  before do
    create(:cookbook_collaborator, resourceable: cookbook, user: suzie)
  end

  def navigate_to_cookbook
    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end
  end

  it 'allows the owner to remove a collaborator', use_poltergeist: true do
    sign_in(sally)
    navigate_to_cookbook

    find('[rel*=remove-cookbook-collaborator]').trigger('click')
    expect(page).to have_no_css('div.gravatar-container')
  end

  it 'allows a collaborator to remove herself', use_poltergeist: true do
    sign_in(suzie)
    navigate_to_cookbook

    find('[rel*=remove-cookbook-collaborator]').trigger('click')
    expect(page).to have_no_css('div.gravatar-container')
  end

  context 'adding groups of collaborators' do
    let!(:admin_group_member) { create(:group_member, admin: true, user: sally) }
    let!(:group) { admin_group_member.group }
    let!(:non_admin_group_member) { create(:group_member, group: group) }

    before do
      sign_in(sally)
      navigate_to_cookbook

      expect(group.group_members).to include(admin_group_member, non_admin_group_member)
      find('#manage').click
      find('[rel*=add-collaborator]').click
      obj = find('.groups').set(group.id)

      click_button('Add')
    end

    it 'shows the group name' do
      expect(page).to have_link(group.name)
    end

    it 'allows the owner to add a group of collaborators' do
      expect(page).to have_link("#{admin_group_member.user.first_name} #{admin_group_member.user.last_name}", href: user_path(admin_group_member.user))
      expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
    end

    context 'when a member is added to the group' do
      let(:existing_user) { create(:user) }

      before do
        visit group_path(group)
        click_link('Add Member')
        fill_in('User ID', with: "#{existing_user.id}")
        click_button('Add Member')
        navigate_to_cookbook
      end

      it 'adds the member as a contributor to the cookbook' do
        expect(page).to have_link("#{existing_user.first_name} #{existing_user.last_name}", href: user_path(existing_user))
      end

      context 'when a member is removed from a group' do
        before do
          visit group_path(group)
        end

        it 'removes the member as a contributor on the cookbook' do
          within('ul#members') do
            click_link('Remove', match: :first)
          end

          navigate_to_cookbook
          expect(page).to_not have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
        end
      end
    end

    context 'removing groups of collaborators' do
      before do
        click_link('Remove Group')
      end

      it 'removes the group name from the cookbook page' do
        expect(page).to_not have_link(group.name)
      end

      it 'removes the group members as collaborators' do
        # NOTE: The admin_group_member is also the owner of the cookbook, and therefore will remain on the page as the owner
        expect(page).to_not have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
      end
    end
  end
end
