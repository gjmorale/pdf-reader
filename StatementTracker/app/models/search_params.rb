class SearchParams
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

	attr_accessor :date_from
	attr_accessor :date_to
	attr_accessor :periodicities
	attr_accessor :ifs
	attr_accessor :name
	attr_accessor :rut
	attr_accessor :handlers
	attr_accessor :statuses

  def initialize(attributes = {})
  	SearchParams.date_from_attribute "date_from", attributes
  	SearchParams.date_from_attribute "date_to", attributes
    attributes.each do |name, value|
      send("#{name}=", value) unless name =~ /\(*\)/
    end
    @ifs ||= []
    @periodicities ||= []
    @handlers ||= []
    @statuses ||= []
    puts @handlers.inspect
  end

  def self.date_from_attribute name, attributes
  	puts "DATE: #{attributes.inspect}"
  	if year = attributes["#{name}(1i)"]
  		unless year.empty?
  			month = attributes["#{name}(2i)"]
  			day = attributes["#{name}(3i)"]
  			attributes["#{name}"] = "#{day}-#{month}-#{year}"
  		end
  	end
  end

	def serialize
		JSON.generate({
			date_from: @date_from,
			date_to: @date_to,
			periodicities: @periodicities,
			ifs: @ifs,
			name: @name,
			rut: @rut,
			handlers: @handlers,
			statuses: @statuses
			})
	end

	def self.deserialize string
		return SearchParams.new unless string
		return SearchParams.new JSON.parse(string)
	end

  def persisted?
    false
  end

  def date type
		d_f = m_f = y_f = d_t = m_t = y_t = nil
		d_f, m_f, y_f = date_from.split('-').map{|d| d.empty? ? nil : d} if date_from
		d_t, m_t, y_t = date_to.split('-').map{|d| d.empty? ? nil : d} if date_to
  	case type
  	when :year_from
  		return y_f
  	when :month_from
  		return m_f
  	when :day_from
  		return d_f
  	when :year_to
  		return y_t
  	when :month_to
  		return m_t
  	when :day_to
  		return d_t
  	end
  end

  def filter query
		if name
			query = query.where("societies.name LIKE ?", "%#{name}%")
		end
		if periodicities.any?
			query = query.where("taxes.periodicity IN (?)", periodicities)
		end
		if ifs.any?
			query = query.where("taxes.bank_id IN (?)", ifs)
		end
		if date_from
			d_f, m_f, y_f = date_from.split('-').map{|d| d.to_i}
			if d_f == 1
				d_f = 0
				m_f = 0 if m_f == 1
			end
			date = y_f*433+m_f*36+d_f
			query = query.where("sequences.year*433+sequences.month*36+(sequences.week*7-sequences.week%7)+sequences.day >= ?", date)
		end
		if date_to
			d_t, m_t, y_t = date_to.split('-').map{|d| d.to_i}
			#Check border case ej: mar-31 -> (mar-35 or apr-0)
			date = y_t*433+m_t*36+d_t
			query = query.where("sequences.year*433+sequences.month*36+(sequences.week*7-sequences.week%7)+sequences.day <= ?", date)
		end
		if handlers.any?
			query = query.where("statements.handler_id IN (?)", handlers)
		end
		if statuses.any?
			query = query.where("statements.status_id IN (?)", statuses)
		end
		query.distinct
  end

end