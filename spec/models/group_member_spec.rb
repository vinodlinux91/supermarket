require 'spec_helper'

describe GroupMember do
  context 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
  end
end
