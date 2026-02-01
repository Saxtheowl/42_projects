# frozen_string_literal: true

class CreateCuicuis < ActiveRecord::Migration[7.2]
  def change
    create_table :cuicuis do |t|
      t.text :content
      t.integer :user_id

      t.timestamps
    end
  end
end
