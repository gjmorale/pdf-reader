class DateParams
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

	attr_accessor :date
	attr_accessor :periodicity

  def initialize(attributes = {})
  	self.class.date_from_attribute "date", attributes
    attributes.each do |name, value|
      send("#{name}=", value) unless name =~ /\(*\)/
    end
    if @date and @date.is_a? Date
			case periodicity
			when Tax::Periodicity::ANNUAL
				@date = @date.end_of_year
			when Tax::Periodicity::MONTHLY
				@date = @date.end_of_month
			when Tax::Periodicity::WEEKLY
				@date = @date.end_of_week
			when Tax::Periodicity::DAILY
				@date = @date
			end
		end
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
			date: @date,
			periodicity: @periodicity
			})
	end

	def self.deserialize string
		return DateParams.new unless string
		return DateParams.new JSON.parse(string)
	end

	#Makes the form helper think it's an instantiated resource
  def persisted?
    false
  end

  def filter query, distinct: true
		query = query.where("taxes.periodicity = ?", periodicity)
		query = query.where("sequences.date <= ?", date)
		case periodicity
		when Tax::Periodicity::ANNUAL
			query = query.where("sequences.date >= ?", date.beginning_of_year)
		when Tax::Periodicity::MONTHLY
			query = query.where("sequences.date >= ?", date.beginning_of_month)
		when Tax::Periodicity::WEEKLY
			query = query.where("sequences.date >= ?", date.beginning_of_week)
		when Tax::Periodicity::DAILY
			query = query.where("sequences.date >= ?", date)
		end
		query = query.distinct if distinct
		query
  end

  def filter_quantities query
  		date ||= (Date.current-1.month).end_of_month
  		periodicity ||= Tax::Periodicity::MONTHLY
		seq_join = "LEFT JOIN "
		seq_q = "sequences.date <= '#{date}' AND "
		case periodicity
		when Tax::Periodicity::ANNUAL
			seq_q << "sequences.date >= '#{date.beginning_of_year}'"
		when Tax::Periodicity::MONTHLY
			seq_q << "sequences.date >= '#{date.beginning_of_month}'"
		when Tax::Periodicity::WEEKLY
			seq_q << "sequences.date >= '#{date.beginning_of_week}'"
		when Tax::Periodicity::DAILY
			seq_q << "sequences.date >= '#{date}'"
		end
		seq_join << "(" << Sequence.where(seq_q).to_sql << ") AS seqs"
		seq_join << " ON (seqs.tax_id = taxes.id"#sequences.date <= date(#{date+2.years}) AND "
		seq_join << ")"
		seq_join << " LEFT JOIN statements ON statements.sequence_id = seqs.id"
		query = query.joins(seq_join).group('taxes.id, seqs.id')
		select = 'taxes.id AS t_id'
		select << ', seqs.id AS s_id'
		select << ', IFNULL(seqs.quantity,taxes.quantity) AS q_expected'
		select << ', COUNT(statements.id) AS q_recieved'
		query = query.select(select)
		query = query.where('taxes.periodicity = ?', periodicity)
  end

end