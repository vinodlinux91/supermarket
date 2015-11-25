class GroupMembersController < ApplicationController
  include CollaboratorProcessing

  def create
    user_ids = group_member_params[:user_ids].split(',')

    if user_ids.present?
      user_ids.each do |user_id|
        group_member = GroupMember.new(
          user_id: user_id,
          group_id: group_member_params[:group_id]
        )

        if group_member.save
          group_resources(group_member).each do |resource|
            add_users_as_collaborators(resource, group_member.user.id.to_s, group_member.group.id)
          end
        else
          flash[:warning] = group_member.errors.full_messages.join(', ')
          redirect_to group_path(group_member_params[:group_id])
          return
        end
      end

      flash[:notice] = "Members successfully added!"
      redirect_to group_path(group_member_params[:group_id])
    end

    redirect_to group_path(group_member_params[:group_id])
  end

  def destroy
    @group_member = GroupMember.find(params[:id])
    if @group_member.destroy

      group_resources(@group_member).each do |resource|
        # TO DO - handle cases where user may have been added as a collaborator
        # before being added to the group, or added as a collaborator through multiple groups
        collaborator = resource.collaborators.where(user_id: @group_member.user_id).first
        remove_collaborator(collaborator)
      end

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
    params.require(:group_member).permit(:user_id, :group_id, :user_ids)
  end

  def current_user_admin?
    @group_member.group.group_members.where(user_id: current_user.id, admin: true).present?
  end

  def group_resources(group_member)
    group_member.group.group_resources.collect {|group_resource| group_resource.resourceable}
  end

  def add_group_members(user_ids)
    user_ids.each do |user_id|
      group_member = GroupMember.new(
        user_id: user_id,
        group_id: group_member_params[:group_id]
      )

      if group_member.save
        group_resources(group_member).each do |resource|
          add_users_as_collaborators(resource, group_member.user.id.to_s, group_member.group.id)
        end
      else
        flash[:warning] = 'An error has occurred'
        not_found!
      end
    end
  end
end
