class SystemEmail < ActiveRecord::Base
  has_many :email_preferences
  validates :name, presence: true
end
