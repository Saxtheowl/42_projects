class CreateActivityLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_logs do |t|
      t.references :user, foreign_key: true
      t.string :action
      t.references :trackable, polymorphic: true
      t.text :details

      t.timestamps
    end
  end
end
