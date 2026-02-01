class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :edited_by_id
      t.datetime :edited_at

      t.timestamps null: false
    end

    add_index :posts, :title, unique: true
    add_index :posts, :edited_by_id
  end
end
