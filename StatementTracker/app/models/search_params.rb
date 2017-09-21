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
  	attributes[:date_to] ||= attributes[:date_from].end_of_month if attributes[:date_from]
    attributes.each do |name, value|
      send("#{name}=", value) unless name =~ /\(*\)/
    end
    @ifs ||= []
    @periodicities ||= []
    @handlers ||= []
    @statuses ||= []
  end

  def self.date_from_attribute name, attributes
  	if attributes[name]
  		attributes[name] = Date.parse attributes[name]
  	else
	  	if year = attributes["#{name}(1i)"]
	  		unless year.empty?
	  			month = attributes["#{name}(2i)"]
	  			day = attributes["#{name}(3i)"]
	  			checkdate = Date.new(year.to_i, month.to_i, -1)
	  			attributes["#{name}"] = Date.new(year.to_i,month.to_i,[day.to_i,checkdate.day].min)
	  		end
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

	#MAkes the form helper think it's an instantiated resource
  def persisted?
    false
  end

  def date type
  	raise #TODO: DELETE IF NOT RAISED
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
		if date_to
			query = query.where("sequences.date <= ?", date_to)
		end
		if date_from 
			query_s = "("
			query_p = []
			query_s << "taxes.periodicity = '#{Tax::Periodicity::ANNUAL}' AND sequences.date >= ?"
			query_p << date_from.beginning_of_year
			query_s << " OR "
			query_s << "taxes.periodicity = '#{Tax::Periodicity::MONTHLY}' AND sequences.date >= ?"
			query_p << date_from.beginning_of_month
			query_s << " OR "
			query_s << "taxes.periodicity = '#{Tax::Periodicity::WEEKLY}' AND sequences.date >= ?"
			query_p << date_from.beginning_of_week
			query_s << " OR "
			query_s << "taxes.periodicity = '#{Tax::Periodicity::DAILY}' AND sequences.date >= ?"
			query_p << date_from
			query_s << ")"
			query = query.where(query_s, *query_p)
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