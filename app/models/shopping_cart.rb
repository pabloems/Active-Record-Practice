# == Schema Information
#
# Table name: shopping_carts
#
#  id         :bigint           not null, primary key
#  total      :integer          default(0)
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(FALSE)
#  status     :integer          default(0)
#
class ShoppingCart < ApplicationRecord

  include AASM

  belongs_to :user
  has_many :shopping_cart_products
  has_many :products, through: :shopping_cart_products

  # Manejo de estados
  # genera un "scope"
  enum status: [ :created, :canceled, :payed, :completed]

  aasm column: 'status' do

    state :created, initial: true
    state :canceled
    state :payed
    state :completed

    event :cancel do
      transitions from: :created, to: :canceled
    end

    event :pay do
      transitions from: :created, to: :payed
    end

    event :complete do
      transitions from: :payed, to: :completed
    end

  end

  # Modificar precio en centavos de dolar
  def price
    self.total / 100
  end

  # Método para actualizar el total del ShoppingCart
  def update_total!
    self.update(total: self.get_total)
  end

  def payed!

    # Nos sirve paraobtener  los cambios de stock
    #  cuando se genera una resta del stock
    # por un carro de compras payed
    # IMPORTANTE ! EN UPDATE! 
    # para obtener un rollback
    # en caso de que no exista stock
    ActiveRecord::Base.transaction do

      self.update!(status: :payed)

      self.products.each do |product|

      # find_by nos entregará el primer resultado que cumpla con la condición
      quantity = ShoppingCartProduct.find_by(shopping_cart_id: self.id, product_id: product.id).quantity

        product.with_lock do
          # sleep(30.seconds)
          product.update!(stock: product.stock - quantity)
        end

      end

    end

  end



  def get_total

    Product.joins(:shopping_cart_products)
    .where(shopping_cart_products:{shopping_cart_id: self.id})
    .select('SUM(products.price * shopping_cart_products.quantity) AS t')[0].t


    # con join tables
    # ShoppingCart.joins(:shopping_cart_products)
    #   .joins(:products)
    #   .where(shopping_carts: {id: self.id})
    #   .group(:shopping_cart_products)
    #   .select('SUM(products.price) AS total')[0].total
      # SELECT NOS AYUDA A ELEGIR UNA TABLA Y COLUMNA EN ESPECÍFICO
      # EN EL INTERIOR DEL () ES CÓDIGO SQL
      # El total se genera de forma dinamica al hacer la consulta sql
      # Obtener total  ShoppingCart.last-or-id.get_total
  end


# nos permite obtener productos del carrito de compra
# y la cantidad de cada uno
  # def products
  #   # Hacemos el join de shopping_cart_products con product
  #   # Donde shoppin_cart_products tendra
  #   # Un id = metodo de clase.id (shopping_cart)
  #   Product.joins(:shopping_cart_products)
  #   .where(shopping_cart_products: { shopping_cart_id: self.id})
  #   .group('products.id')
  #   .select('COUNT(products.id) AS quantity, products.id, products.title, products.price')
  #   # ShoppingCart.last.products.last.quantity
  #   # pegar en la terminar para conocer cantidad de unidades por producto
  # end



#   def get_total
# # Nos ayuda a establecer el método total del ShoppingCart
#     total = 0

#     self.products.each do |product|
#       total += product.price
#     end

#     return total

#     # instanciando el shopping cart podemos obtener el total con
#     # shopping_cart.get_total

#   end

end
