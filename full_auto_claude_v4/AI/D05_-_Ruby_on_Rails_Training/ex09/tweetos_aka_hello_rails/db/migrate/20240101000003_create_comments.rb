# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :cuicui_id
      t.integer :user_id

      t.timestamps
    end
  end
end
