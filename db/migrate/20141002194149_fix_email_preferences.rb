class FixEmailPreferences < ActiveRecord::Migration
  def change
    add_column :email_preferences, :system_email_id, :integer, null: false
    remove_column :email_preferences, :slug
    remove_column :email_preferences, :description
    add_index :email_preferences, :system_email_id
  end
end
