class RemoveEmailPreferencesFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :email_preferences
  end
end
