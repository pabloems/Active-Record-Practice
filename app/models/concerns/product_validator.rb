class ProductValidator < ActiveModel::Validator

  def validate(record)
      if record.stock < 0
        record.errors.add(:stock, 'No hay stock suficiente.')
      end
    # self.validate_stock(record)
  end

  # def validate_stock(record)
  #   end
  # end

end