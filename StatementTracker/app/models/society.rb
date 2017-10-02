class Society < ApplicationRecord
  extend ActsAsTree::TreeView

  acts_as_tree order: "name"

  has_many :taxes, dependent: :destroy, inverse_of: :society
  has_many :banks, through: :taxes
  has_many :sequences, through: :taxes
  has_many :statements, through: :sequences

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :parent_id

  accepts_nested_attributes_for :children, allow_destroy: true
  accepts_nested_attributes_for :taxes, allow_destroy: true

  #validates_uniqueness_of :rut, scope: :name #DANGEROUS IN DEBUG

  	def self.new_from_folder folder, parent
  		soc = nil
  		if not parent
  			soc = self.find_by(name: folder, parent: nil)
  			soc ||= Society.roots.first #DEBUG
  		elsif parent.persisted?
  			soc = parent.children.find_by(name: folder)
  			soc ||= parent.children.build(name: folder)
  		else
  			soc = self.new(name: folder)
  		end
  		soc
  	end

	def to_s
		name
	end

	def self.treefy societies
		posibilities = Society.roots.to_a
		final = []
		societies.each do |society|
			ids = society.ancestors.map{|a| a.id}
			posibilities.each do |posibility|
				if ids.include? posibility.id
					final << posibility
					posibilities.delete(posibility)
				end
			end
			unless posibilities.any?
				break
			end
		end
		final
	end 

	def treefy societies
		posibilities = children.to_a
		final = []
		societies.each do |society|
			ids = society.self_and_ancestors.map{|a| a.id}
			posibilities.each do |posibility|
				if ids.include? posibility.id
					final << posibility
					posibilities.delete(posibility)
				end
			end
			unless posibilities.any?
				break
			end
		end
		final
	end 

	def self.filter params
		query = Society.all
		query = query.left_outer_joins(taxes: [sequences: [statements: :status]])
		params.filter query
	end

	def filter params
		query = Society.where(id: descendants.map{|d| d.id})
		query = query.left_outer_joins(taxes: [sequences: [statements: :status]])
		params.filter query
	end

	def time_nodes params
		query = sequences
		query = query.left_outer_joins(statements: :status)
		params.filter query
	end

	def statement_nodes params
		query = statements
		query = query. left_outer_joins(:status)
		query = params.filter query
	end

	def if_nodes params
		query = taxes
		query = query.left_outer_joins(sequences: [statements: :status])
		params.filter query
	end

	def progress params
	    means = all_times(params).group("taxes.id", "sequences.id").sum("statement_statuses.progress")
	    return "0" unless means.any?
	    q = p = 0
	    means.each do |m|
	    	q += Tax.find(m[0][0]).quantity
	    	p += m[1]
	    end
	    return 0 if p == 0
	    return p/q
	end

	def self_progress params
		#DEPRECATED
	    means = time_nodes(params).group("taxes.id", "sequences.id").sum("statement_statuses.progress")
	    return "0" unless means.any?
	    q = p = 0
	    means.each do |m|
	    	q += Tax.find(m[0][0]).quantity
	    	p += m[1]
	    end
	    return 0 if p == 0
	    return p/q
	end

	def all_times params
		query = Sequence.all
		query = query.left_outer_joins(tax: :society, statements: :status)
		query = query.where("societies.id IN (?)",descendant_ids)
		params.filter(query)
	end

	def all_ifs params
		query = Tax.all
		query = query.left_outer_joins(:society, sequences: [statements: :status])
		query = query.where("societies.id IN (?)",descendant_ids)
		params.filter(query)
	end

	def all_statements params
		query = Statement.all
		query = query.left_outer_joins(:status, sequence: [tax: :society])
		query = query.where("societies.id IN (?)",descendant_ids)
		params.filter(query)
	end

	def descendant_ids
		self_and_descendants.map{|s| s.id}
	end

	def path
		self.self_and_ancestors.reverse.join('/')
	end

	def expected date_params
		targets = Tax.where(society_id: descendant_ids)
		date_params.filter_quantity targets
		targets.sum(&:quantity)
	end

	def recieved date_params
		targets = Society.where(id: descendant_ids)
		targets = targets.joins(taxes: {sequences: :statements})
		query = date_params.filter targets, distinct: false
		query.size
	end

	def period_progress date_params
		n = expected(date_params)
		return 100 if n == 0
		targets = Society.where(id: descendant_ids)
		targets = targets.joins(taxes: {sequences: {statements: :status}})	
		status = StatementStatus.arel_table	
		query = date_params.filter targets, distinct: false
		query = query.select(status[:progress].as("status_progress"))
		query.sum(&:status_progress)/n
	end

	def inherited_ifs
		targets = Tax.where(society_id: descendant_ids).size
	end

end
=begin RECURSIVENESS REQUIRES sql3driver >= 3.8.1
  def descendents
    self_and_descendents - [self]
  end

  def self_and_descendents
    self.class.tree_for(self)
  end

  private

	  def self.tree_for(instance)
	    where("#{table_name}.id IN (#{tree_sql_for(instance)})").order("#{table_name}.id")
	  end

	  def self.tree_sql_for(instance)
	    tree_sql =  <<-SQL
	      WITH RECURSIVE search_tree(id, path) AS (
	          SELECT id, ARRAY[id]
	          FROM #{table_name}
	          WHERE id = #{instance.id}
	        UNION ALL
	          SELECT #{table_name}.id, path || #{table_name}.id
	          FROM search_tree
	          JOIN #{table_name} ON #{table_name}.parent_id = search_tree.id
	          WHERE NOT #{table_name}.id = ANY(path)
	      )
	      SELECT id FROM search_tree ORDER BY path
	    SQL
	  end
=end
