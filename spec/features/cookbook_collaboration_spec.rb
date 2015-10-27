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
    let!(:group_member) { create(:group_member, user: sally) }
    let!(:group) { group_member.group }
    let!(:group_member2) { create(:group_member, group: group) }

    before do
      sign_in(sally)
      navigate_to_cookbook

      expect(group.group_members).to include(group_member, group_member2)
    end

    it 'allows the owner to add a group of collaborators' do
      find('#manage').click
      find('[rel*=add-collaborator]').click
      obj = find('.groups').set(group.id)

      click_button('Add')


      expect(page).to have_link("#{group_member.user.first_name} #{group_member.user.last_name}", href: user_path(group_member.user))
      expect(page).to have_link("#{group_member2.user.first_name} #{group_member2.user.last_name}", href: user_path(group_member2.user))
    end

    context 'when a member is added to the group' do
      let(:existing_user) { create(:user) }

      before do
        expect(page).to_not have_link("#{existing_user.first_name} #{existing_user.last_name}", href: user_path(existing_user))
      end

      it 'adds the member as a contributor to the cookbook' do
        visit group_path(group)
        click_link('Add Member')
        fill_in('User ID', with: "#{existing_user.id}")
        click_button('Add Member')
        navigate_to_cookbook
        expect(page).to have_link("#{existing_user.first_name} #{existing_user.last_name}", href: user_path(existing_user))
      end
    end
  end
end
