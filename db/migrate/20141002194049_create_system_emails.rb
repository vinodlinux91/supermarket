class CreateSystemEmails < ActiveRecord::Migration
  def change
    create_table :system_emails do |t|
      t.string :name
      t.timestamps
    end
  end
end
