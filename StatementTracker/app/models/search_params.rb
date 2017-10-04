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
  	SearchParams.attribute_to_date "date_from", attributes
  	SearchParams.attribute_to_date "date_to", attributes
  	attributes["date_to"] ||= attributes["date_from"]
  	attributes["date_to"] = attributes["date_to"].end_of_month if attributes["date_to"]
    attributes.each do |name, value|
      send("#{name}=", value) unless name =~ /\(*\)/
    end
    @ifs ||= []
    @periodicities ||= []
    @handlers ||= []
    @handlers = @handlers.map{|h| h == "on" ? nil : h}
    @statuses ||= []
  end

  def self.attribute_to_date name, attributes
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

	#Makes the form helper think it's an instantiated resource
  def persisted?
    false
  end

  def filter query
		if name and not name.empty?
			#query = query.where("societies.name LIKE ? COLLATE utf8_general_ci", "%#{name}%") NOT SUPPORTED IN SQLite3 UBUNTU 12.04
			query = query.where("societies.name LIKE ? ", "%#{name}%")
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
			query_s << ") OR ("
			query_s << "taxes.periodicity = '#{Tax::Periodicity::MONTHLY}' AND sequences.date >= ?"
			query_p << date_from.beginning_of_month
			query_s << ") OR ("
			query_s << "taxes.periodicity = '#{Tax::Periodicity::WEEKLY}' AND sequences.date >= ?"
			query_p << date_from.beginning_of_week
			query_s << ") OR ("
			query_s << "taxes.periodicity = '#{Tax::Periodicity::DAILY}' AND sequences.date >= ?"
			query_p << date_from
			query_s << ")"
			query = query.where(query_s, *query_p)
		end
		if handlers.size > 0
			if handlers.any? {|h| h.nil?}
				ids = handlers.select{|h| !!h}
				query = query.where("statements.handler_id IN (?) OR statements.handler_id IS NULL", ids)
			else
				query = query.where("statements.handler_id IN (?)", handlers)
			end
		end
		if statuses.any?
			query = query.where("statements.status_id IN (?)", statuses)
		end
		query.distinct
  end

end