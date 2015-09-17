require 'spec_helper'

describe GroupsHelper do
  describe '#admin_member?' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    let!(:member) do
      create(:group_member)
    end

    let(:admin_user) { create(:user) }

    let!(:admin_member) do
      create(:admin_group_member)
    end

  end
end
