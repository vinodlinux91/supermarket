module GroupsHelper
  def admin_member?(user, group)
    group.group_members.where(user_id: user.id, admin: true).present?
  end
end
