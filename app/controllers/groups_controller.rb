class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      GroupMember.create!(user: current_user, group: @group)
      flash[:notice] = 'Group successfully created!'
      redirect_to group_path(@group)
    else
      flash[:warning] = 'An error has occurred'
      redirect_to new_group_path
    end
  end

  def show
    @group = Group.find(params[:id])
    @members = @group.members
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
