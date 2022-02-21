# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  title      :string
#  code       :string
#  price      :integer          default(0)
#  stock      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Product < ApplicationRecord

  has_many :shopping_cart_products
  # save Callback´s
  before_create :validate_product
  after_create :send_notification

  # Callback with conditional
  after_create :push_notification, if: :discount?

  # Validates
    validates :title, presence: {message: 'Es necesario definir un valor por título'}
    validates :code, presence: {message: 'Es necesario definir un valor para el código'}

    validates :code, uniqueness: {message: 'El código: %{value} ya se encuentra en uso'}

    # validates :price, length: {minimum:3, maximum: 10}
    validates :price, length: {in: 3..10, message: 'El precio está fuera de rango (Min: 3, Max: 10)'}, if: :has_price?

    # La sintaxis cambia con validaciones propias

    # Validación propia
    # Se ejecutan después que las de active record
    validate :code_validate

    # Validación presente en la carpeta ../concerns
    validates_with ProductValidator

  # Scope's

    # Muestra todos los products con stock >1
    # Filtro de stock_positivo
    scope :available, -> (min = 1) { where('stock >= ?', min) }

    # Filtro de precio descendente
    scope :order_price_desc, -> { order('price DESC')}

    # Mezcla de dos Scope´s
    scope :available_and_order_price_desc, -> { available.order_price_desc }

  def self.top_5_available
    self.available.order_price_desc.limit(5).select(:title, :code)
  end

  def total
    self.price / 100
  end

  def has_price?
    # si el product posee un precio
    # y este es > 0 ...no es gratuito
    !self.price.nil? && self.price > 0
  end

  def discount?
    self.total < 5
  end

  private

  def code_validate
    # Si el código del product es nil o longitud < 3
    # Muestra dicho error
    if self.code.nil? || self.code.length < 3
      self.errors.add(:code, 'El codigo debe poseer al menos 3 caracteres.')
    end
  end

  def push_notification
    puts "\n\n\n>>> Un nuevo producto en descuento ya se encuentra disponible: #{self.title}"
  end


  def validate_product
    puts "\n\n\n>>> Un nuevo producto será añadido al almacen"
  end

  def send_notification
    puts "\n\n\n>>> Un nuevo producto fue añadido al almacen: #{self.title} - $#{self.total} USD"
  end

end
