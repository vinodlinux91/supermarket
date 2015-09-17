require 'spec_helper'

describe GroupsHelper do
  describe '#admin_member?' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    let!(:member) do
      create(:group_member, user: user, group: group)
    end

    let(:admin_user) { create(:user) }

    let!(:admin_member) do
      create(:admin_group_member, user: admin_user, group: group)
    end

    context 'when then user is an admin member' do
      it 'returns true' do
        expect(helper.admin_member?(admin_user, group)).to eq(true)
      end
    end

    context 'when the user is NOT an admin member' do
      it 'returns false' do
        expect(helper.admin_member?(user, group)).to eq(false)
      end
    end

  end
end
