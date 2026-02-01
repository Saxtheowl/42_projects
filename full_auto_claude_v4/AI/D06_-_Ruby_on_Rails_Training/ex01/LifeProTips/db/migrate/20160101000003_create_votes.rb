class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :post, index: true, foreign_key: true, null: false
      t.integer :value, null: false

      t.timestamps null: false
    end

    add_index :votes, [:user_id, :post_id], unique: true
  end
end
