class Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :group_members
  has_many :members, through: :group_members, source: :user
end
