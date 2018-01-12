class GlobalParams
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

	attr_accessor :date_from
	attr_accessor :date_to
	attr_accessor :periodicities
	attr_accessor :periodicity
	attr_accessor :ifs
	attr_accessor :name
	attr_accessor :rut
	attr_accessor :handlers
	attr_accessor :statuses

	def initialize(attributes = {})
		GlobalParams.dated_attributes attributes
		attributes.each do |name, value|
			send("#{name}=", value) rescue
			puts "#{name}=#{value}:#{value.class}"
		end
		@ifs 						||= []
		@periodicities 	||= [@periodicity || Tax::Periodicity::MONTHLY]
		@handlers 			||= []
		@handlers 			= @handlers.map{|h| h == "on" ? nil : h}
		@statuses 			||= []
	end

	def self.dated_attributes attributes
		return unless attributes
		possible = {}
		attributes.each do |k,v|
			key = period = nil
			case k
			when /\(1i\)$/
				key = k[/^.+(?=\(1i\)$)/]
				period = :year
			when /\(2i\)$/
				key = k[/^.+(?=\(2i\)$)/]
				period = :month
			when /\(3i\)$/
				key = k[/^.+(?=\(3i\)$)/]
				period = :day
			else
				attributes[k] = Date.parse(v) if v and v.is_a? String and v[/^(19|20)\d{2}-(0?[1-9]|1[12])-[0-3]?\d$/]
			end
			if key
				possible[key] ||= {}
				possible[key][period] = v.to_i
			end
		end 
		possible.each do |k,v|
			attributes[k] = Date.new(v[:year],v[:month],v[:day]) if v[:year] != 0
			["#{k}(1i)", "#{k}(2i)", "#{k}(3i)"].each{|key| attributes.delete(key)}
		end
	end

	def serialize
		JSON.generate({
			date_from: @date_from,
			date_to: @date_to,
			periodicities: @periodicities,
			periodicity: @periodicity,
			ifs: @ifs,
			name: @name,
			rut: @rut,
			handlers: @handlers,
			statuses: @statuses
		})
	end

	def self.deserialize string
		return GlobalParams.new unless string
		return GlobalParams.new JSON.parse(string)
	end

	#Makes the form helper think it's an instantiated resource
	def persisted?
		false
	end

	def filter query, distinct: true, blanks: false
		query = query.where("societies.active = ?", true)
		query = query.where("taxes.active = ?", true)
		query = query.where("societies.name LIKE ? ", "%#{name}%") 			if name and not name.empty?
		#query = query.where("societies.name LIKE ? COLLATE utf8_general_ci", "%#{name}%") NOT SUPPORTED IN SQLite3 UBUNTU 12.04
		query = query.where("taxes.periodicity IN (?)", periodicities) 	if periodicities.any?
		query = query.where("taxes.bank_id IN (?)", ifs) 								if ifs.any?
		query = query.where("statements.status_id IN (?)", statuses) 		if statuses.any?
		include_null = blanks ? ' OR sequences.id IS NULL' : ''
		if date_to and not date_from
			query = query.where("(sequences.date = ? #{include_null})", date_to)
		elsif date_from and not date_to
			query = query.where("(sequences.start_date = ? #{include_null})", date_from)
		elsif date_to and date_from
			query = query.where("((sequences.date <= ? AND sequences.start_date >= ?) #{include_null})", date_to, date_from)
		end
		if handlers.size > 0
			if handlers.any? {|h| h.nil?}
				ids = handlers.select{|h| !!h}
				query = query.where("statements.handler_id IN (?) OR statements.handler_id IS NULL", ids)
			else
				query = query.where("statements.handler_id IN (?)", handlers)
			end
		end
		query = query.distinct if distinct
		query
	end

  def filter_quantities query, distinct: true, blanks: false
  	query = filter query, distinct: distinct, blanks: blanks
  	query.group("taxes.id", "sequences.id")
  	.select([
	    "taxes.id AS taxes_id, ",
	    "sequences.id AS sequences_id, ",
  		"COUNT(statements.id) AS q_recieved, ",
	    "IFNULL(taxes.quantity, sequences.quantity) AS q_expected"
  	].join)
  end

  def filter_progress query, distinct: true, blanks: false
  	query = filter query, distinct: distinct, blanks: blanks
  	query.group("taxes.id", "sequences.id")
  	.select([
	    "taxes.id AS taxes_id, ",
	    "sequences.id AS sequences_id, ",
  		"SUM(statement_statuses.progress) AS q_progress, ",
	    "IFNULL(taxes.quantity, sequences.quantity) AS q_quantity"
  	].join)
  end

end