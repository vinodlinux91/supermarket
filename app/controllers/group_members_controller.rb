class GroupMembersController < ApplicationController
  def new
    @group_member = GroupMember.new
  end
end
