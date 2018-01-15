class MBI::CashTransactions < MBI::CashTransactionTable
  def load
    @name = "movimientos de caja"
    @headers = []
      headers << HeaderField.new("Fecha Operación", headers.size, Custom::DATE_2, true)     # 0
      headers << HeaderField.new("Fecha Liquidación", headers.size, Custom::DATE_2)         # 1
      headers << HeaderField.new("Moneda", headers.size, Setup::Type::LABEL)                # 2
      headers << HeaderField.new("Tipo Movimiento", headers.size, Setup::Type::LABEL)       # 3
      headers << HeaderField.new("Nemotécnico/Glosa", headers.size, Setup::Type::LABEL)     # 4
      headers << HeaderField.new("Ingreso", headers.size, Setup::Type::INTEGER)             # 5
      headers << HeaderField.new("Egreso", headers.size, Setup::Type::INTEGER)              # 6
      headers << HeaderField.new("Saldo", headers.size, Setup::Type::INTEGER)               # 7
    @skips = ['Saldo Anterior','Cuenta']
    @mov_map = {
      fecha_movimiento:   0,
      fecha_pago:     1,
      id_ti_valor1: 4,
      id_ti_valor2: 2,
      concepto:       3,
      abono:        5,
      cargo:        6,
      detalle:      3
    }

  end

end