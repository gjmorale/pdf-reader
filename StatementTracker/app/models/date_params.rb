class DateParams
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

	attr_accessor :date
	attr_accessor :periodicity

  def initialize(attributes = {})
  	SearchParams.date_from_attribute "date", attributes
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

  def filter query
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
		query.distinct
  end

end