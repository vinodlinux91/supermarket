class GroupsController < ApplicationController
  def index
    @groups = Group.all #Will eventually only show groups a user is a member of
  end
end
