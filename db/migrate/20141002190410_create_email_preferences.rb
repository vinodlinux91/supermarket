class CreateEmailPreferences < ActiveRecord::Migration
  def change
    create_table :email_preferences do |t|
      t.references :user, null: false
      t.string :token, null: false
      t.string :slug, null: false
      t.string :description, null: false
      t.timestamps
    end

    add_index :email_preferences, :token
    add_index :email_preferences, [:slug, :user_id], unique: true
  end
end
