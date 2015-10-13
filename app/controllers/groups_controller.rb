class GroupsController < ApplicationController
  def index
    @groups = Group.all

    respond_to do |format|
      format.html
      format.json { render json: @groups.to_json }
    end
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      GroupMember.create!(user: current_user, group: @group, admin: true)
      flash[:notice] = 'Group successfully created!'
      redirect_to group_path(@group)
    else
      flash[:warning] = 'An error has occurred'
      redirect_to new_group_path
    end
  end

  def show
    @group = Group.find(params[:id])
    @admin_members = @group.group_members.where(admin: true)
    @members = @group.group_members.where(admin: nil)
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
