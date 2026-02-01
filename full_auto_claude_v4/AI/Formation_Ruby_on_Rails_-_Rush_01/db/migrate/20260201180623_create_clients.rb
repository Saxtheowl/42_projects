class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.references :company, foreign_key: true
      t.string :position
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
