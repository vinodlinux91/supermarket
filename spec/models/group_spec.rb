require 'spec_helper'

describe Group do
  it 'requires a name' do
    group = Group.new(name: '')
    expect(group).to_not be_valid
  end

  it 'requires a unique name' do
    group1 = create(:group)

    group2 = Group.new(name: group1.name)
    expect(group2).to_not be_valid
  end
end
