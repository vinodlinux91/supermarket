require 'spec_helper'

describe GroupMember do
  context 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
  end

  context 'validations' do
    let!(:user) { create(:user) }
    let!(:group) { create(:group) }

    it 'requires a group id' do
      group_member = GroupMember.new(group: nil, user: user)
      expect(group_member).to_not be_valid
    end

    it 'requires user id' do
      group_member = GroupMember.new(group: group, user: nil)
      expect(group_member).to_not be_valid
    end
  end
end
