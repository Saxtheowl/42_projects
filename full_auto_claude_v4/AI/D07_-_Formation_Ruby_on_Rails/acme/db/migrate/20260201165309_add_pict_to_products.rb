class AddPictToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :pict, :string
  end
end
