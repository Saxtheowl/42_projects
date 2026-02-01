class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :project, foreign_key: true
      t.text :intro
      t.decimal :total
      t.string :status

      t.timestamps
    end
  end
end
