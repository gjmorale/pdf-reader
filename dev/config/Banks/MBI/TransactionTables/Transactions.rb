class MBI::Transactions < MBI::TransactionTable
  def load
    @name = "movimientos de titulos"
    @headers = []
      headers << HeaderField.new("Fecha Operación", headers.size, Setup::Type::DATE, true)  # 0
      headers << HeaderField.new("Fecha Liquidación", headers.size, Setup::Type::DATE)      # 1
      headers << HeaderField.new("Moneda", headers.size, Setup::Type::LABEL)                # 2
      headers << HeaderField.new("Tipo Movimiento", headers.size, Setup::Type::LABEL)       # 3
      headers << HeaderField.new("Clase de Activo", headers.size, Setup::Type::LABEL)       # 4
      headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL)           # 5
      headers << HeaderField.new("Unidades", headers.size, Setup::Type::AMOUNT)             # 6
      headers << HeaderField.new("Precio", headers.size, Custom::FLOAT_2)                   # 7
      headers << HeaderField.new("Gastos", headers.size, Setup::Type::INTEGER)              # 8
      headers << HeaderField.new("Monto Operación", headers.size, Setup::Type::INTEGER)     # 9
    @mov_map = {
      fecha_movimiento:   0,
      fecha_pago:     1,
      concepto:       3,
      id_ti_valor1:     5,
      id_ti1:       "Nemo",
      cantidad1:      6,
      id_ti_valor2_default: "CLP",
      id_ti2:       "Currency",
      precio:       7,
      cantidad2:      9,
      detalle:      4,
      delta: [
      ]
    }
  end

  def parse_movement hash
    hash[:value] = hash[:cantidad1]
    case hash[:concepto]
    when /Compra/i
      hash[:concepto] = 9004
    when /Venta/i
      hash[:concepto] = 9005
    else
      hash[:concepto] = 9000
    end
    hash
  end
end