class AddStatusToShoppingCarts < ActiveRecord::Migration[6.1]
  def change
    add_column :shopping_carts, :status, :integer, default: 0
  end
end


#  4 tipos de estado
# CREADO = 0
# CANCELADO = 1
# PAGADO = 2
# COMPLETADO = 3
