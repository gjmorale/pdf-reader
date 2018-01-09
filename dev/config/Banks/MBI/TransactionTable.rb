class MBI::TransactionTable < TransactionTable
  
  def pre_load *args
    super
    @spanish = true
    @label_index = 0
    @title_limit = 0
  end
  
end

class MBI::CashTransactionTable < CashTransactionTable

  def pre_load *args
    super
    @spanish = true
    @label_index = 0
    @title_limit = 0
  end

  def new_movement args
    args = args.map{|arg| "#{arg}".strip}
    abono = @mov_map[:abono].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:abono]], spanish)
    cargo = @mov_map[:cargo].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:cargo]], spanish)

    id_ti_1 = "Nemo"
    cantidad1 = 0.0
    id_ti_2 = "Currency"
    cantidad2 = (abono - cargo).abs
    if args[@mov_map[:id_ti_valor2]] == "$$"
      args[@mov_map[:id_ti_valor2]] = "CLP"
    end

    if args[@mov_map[:id_ti_valor1]] == "NA"
      args[@mov_map[:id_ti_valor1]] = args[@mov_map[:id_ti_valor2]]
    end

    hash = {
      fecha_movimiento: args[@mov_map[:fecha_movimiento]],
      fecha_pago: args[@mov_map[:fecha_pago]],
      concepto: args[@mov_map[:concepto]],
      id_ti_valor1: args[@mov_map[:id_ti_valor1]],
      id_ti1: id_ti_1, 
      cantidad1: cantidad1,
      id_ti_valor2: args[@mov_map[:id_ti_valor2]],
      id_ti2: id_ti_2, 
      cantidad2: cantidad2,
      detalle: args[@mov_map[:detalle]]
    }

    params = parse_movement hash
    return Movement.new(params) if params
  end

  def parse_movement hash
    case hash[:concepto]
    when /Compra/i
      hash[:concepto] = 9004 # pueden cambiar, no me sé los códigos
    when /Gastos/i
      hash[:concepto] = 9000
    when /Venta/i
      hash[:concepto] = 9005
    when /Rescate/i
      hash[:concepto] = 9000
    else
      hash[:concepto] = 9000
    end
    hash
  end

end


Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 