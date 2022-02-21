class AddActiveToShoppingCarts < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_carts, :active, :boolean, default: false
  end
end
