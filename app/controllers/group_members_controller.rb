class GroupMembersController < ApplicationController
  def new
    @group = Group.find(params[:group])
    @group_member = GroupMember.new(group: Group.find(params[:group]))
  end

  def create
    @group_member = GroupMember.new(group_member_params)
    if @group_member.save

      group_resources.each do |resource|
        add_users_as_collaborators(resource, @group_member.user.id.to_s)
      end

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
      flash[:warning] = 'An error has occurred'
      redirect_to group_path(@group_member.group)
    end
  end

  def make_admin
    @group_member = GroupMember.find(params[:id])

    if current_user_admin?
      @group_member.admin = true
      @group_member.save
      flash[:notice] = 'Member has successfully been made an admin!'
    else
      flash[:error] = 'You must be an admin member of the group to do that.'
    end

    redirect_to group_path(@group_member.group)
  end

  private

  def group_member_params
    params.require(:group_member).permit(:user_id, :group_id)
  end

  def current_user_admin?
    @group_member.group.group_members.where(user_id: current_user.id, admin: true).present?
  end

  def group_resources
    @group_member.group.group_resources.collect {|group_resource| group_resource.resourceable}
  end
end
