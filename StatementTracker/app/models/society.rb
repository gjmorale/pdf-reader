class Society < ApplicationRecord
  extend ActsAsTree::TreeView

  acts_as_tree order: "name"

  has_many :taxes, dependent: :destroy, inverse_of: :society
  has_many :banks, through: :taxes
  has_many :sequences, through: :taxes
  has_many :statements, through: :sequences

  accepts_nested_attributes_for :children, allow_destroy: true
  accepts_nested_attributes_for :taxes, allow_destroy: true

  #validates_uniqueness_of :rut, scope: :name #DANGEROUS IN DEBUG

	def to_s
		name
	end

	def self.treefy societies
		final_socs = []
		societies.each do |soc|
			ancestors = soc.ancestors
			nested = false
			ancestors.each do |anc|
				if societies.include? anc
					nested = true
				else
					final_socs << anc unless final_socs.include? anc
				end
			end
			final_socs << soc unless nested #or soc.invalid?
		end
		final_socs
	end 

	def treefy societies
		final_socs = []
		societies.each do |soc|
			ancestors = soc.ancestors
			nested = false
			ancestors.each do |anc|
				if societies.include? anc
					nested = true
				end
			end
			final_socs << soc unless nested #or soc.invalid?
		end
		final_socs
	end 

	def self.filter params
		query = Society.all
		query = query.left_outer_joins(taxes: [sequences: [statements: :status]])
		aux = params.filter query
		puts aux.inspect
		aux
	end

	def filter params
		query = children
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
		self.ancestors.join('/')
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
