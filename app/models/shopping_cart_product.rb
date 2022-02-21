# == Schema Information
#
# Table name: shopping_cart_products
#
#  id               :bigint           not null, primary key
#  shopping_cart_id :bigint           not null
#  product_id       :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  quantity         :integer          default(1)

class ShoppingCartProduct < ApplicationRecord
  belongs_to :shopping_cart
  belongs_to :product

# El total del carrito de compra es seteado
# Cada vez que se añade o elimina un producto
  after_create  :update_total!
  after_destroy  :update_total!

  private

# se crea un modelo de clase
# cargando otro modelo (shopping_cart)
# y usando su método de clase update_total!
  def update_total!
    self.shopping_cart.update_total!
  end

end
