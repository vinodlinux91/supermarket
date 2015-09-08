class GroupMembersController < ApplicationController
  def new
    @group = Group.find(params[:group])
    @group_member = GroupMember.new(group: Group.find(params[:group]))
  end

  def create
    @group_member = GroupMember.new(group_member_params)
    if @group_member.save
      flash[:notice] = 'Member successfully added!'
      redirect_to group_path(group_member_params[:group_id])
    else
      flash[:warning] = 'An error has occurred'
      redirect_to new_group_member_path
    end
  end

  def destroy
    @group_member = GroupMember.find(params[:id])
    if @group_member.destroy
      flash[:notice] = 'Member successfully removed'
      redirect_to group_path(@group_member.group)
    else
      #flash[:warning] = 'An error has occurred'
      #redirect_to new_group_member_path
    end
  end

  def group_member_params
    params.require(:group_member).permit(:user_id, :group_id)
  end
end
