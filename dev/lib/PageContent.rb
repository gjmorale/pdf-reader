class PageContent

	attr_reader :line_size
	attr_reader :number


	def initialize(page_number, content)
		@number = page_number
		@content = content
		@line_size = @content.lines[0].length
	end 

	def to_s
		@content
	end

	def search(field)
		#puts "searching for #{field.text}"
		position = nil
		xi = 0
		ocurrence_counter = 0
		@content.each_line.with_index do |line, y|
			last_index = 0
			#puts "Line: #{@content.lines[y]}"
			while line[last_index, line.length - last_index].match(field.regex){|m|
					#puts "match!------------------------------------------------------------"
					ocurrence_counter += 1
					xi = last_index + m.offset(0)[0]
					xf = last_index + m.offset(0)[1]
					text = m.to_s
					last_index = xf
					if ocurrence_counter == field.ocurrence
						#puts "Setting!"
						position = TextNode.new(text, xi, xf-1, y) 
						field.position = position
						return true
					end
				}
			end
		end 
		return false
	end

	def search_next(field, offset)
		position = nil
		xi = 0
		@content.lines[offset..-1].each.with_index do |line, y_full|
			y = offset + y_full
			last_index = 0
			while line[last_index, line.length - last_index].match(field.regex){|m|
					xi = last_index + m.offset(0)[0]
					xf = last_index + m.offset(0)[1]
					text = m.to_s
					last_index = xf
					position = TextNode.new(xi, xf-1, y) 
					field.position = position
					return true
				}
			end
		end 
		return false
	end

	def field_offset(field)
		coords = field.position.coords
		y = coords[2]
		line = @content.lines[y]
		left = RegexHelper.rindex(line[0..coords[0]-1])
		left = 0 if left.nil?
		right = RegexHelper.index(line, coords[1]+1)
		right = line.length-1 if right.nil?
		[left,right,y]
	end

	def find_results_right(field)
		range = field_offset field
		field.results.each.with_index do |result, i|
			regex = result.regex
			range[1] = horizontal_search result, range, regex
		end
	end
	
	def horizontal_search(result, range, regex)
		counter = 0
		tolerance = 0
		last_match = ""
		detected = false
		limit = range[1]
		while tolerance <= Setup::Read.horizontal_search_range and range[1] + counter < line_size
			counter += 1
			tolerance += 1 if detected
			text = @content.lines[range[2]][range[1],counter]
			text = RegexHelper.strip_wildchar(text)
			if text.match regex
				detected = true
				tolerance = 0
				last_match = text
				limit = range[1] + counter
			end
		end
		if not last_match.nil? and last_match.match regex
			#text = @content.lines[range[2]][range[1],counter]
			#text = text.delete('€')
			#puts "Last line eval: #{text} and #{last_match}"
			result.result = last_match
		else
			result.result = Result::NOT_FOUND
		end
		return limit
	end

	# Vertical Search
	# row_count: the amount of rows to be recognized
	# header: The header of thecolumn to be recognized
	# Vertical search goes row by row looking for results
	# for the header. The header results must exist
	# initialy and have the same dimensions as the header.
	# For each iteration the headers position and border 
	# is recalculated. This way the information of every
	# result makes the search for the others more accurate.
	def vertical_search(row_count, header)
		done = false
		while not done
			y = header.position.y
			xi = header.position.xi
			xf = header.position.xf
			done = true
			row_count.times do |row|
				#puts "#{xi} #{xf} #{y}"
				y = find_next_row(xi, xf, y)
				#puts "Inverse search: [#{xi},#{index},#{y}]\t => #{header.text}"
				#puts "#{@content.lines[y][xi + 10..index]}"
				downwards_search(header, y, header.results[row])
				done = false if header.recalculate_position
			end
		end
	end

	# Find Next Row
	# xi, xf, y: dimensions of the table header to be evalueated
	# The algorithm starts on the line 'y' and moves to the next one
	# until the line is empty or invalid as a row. Then it moves on
	# until it reaches a valid row and returns it's 'y' coordinate
	def find_next_row(xi, xf, y)
		while not (line = RegexHelper.strip_wildchar(@content.lines[y][xi..xf])).empty?
			#puts "SKIPPING[#{xi},#{xf}] #{@content.lines[y][xi..xf]}"
			y += 1
		end
		while (line = RegexHelper.strip_wildchar(@content.lines[y][xi..xf])).empty?
			#puts "SKIPPING[#{xi},#{xf}] #{@content.lines[y][xi..xf]}"
			y += 1
		end
			#puts "Landed on #{y}: #{@content.lines[y][xi..xf]}"
		return y
	end


	# Count To Bottom
	# xi, xf, y: dimensions of the table header to be evalueated
	# It counts how many valid rows are between the provided coordinates
	# and the bottom field exclusively
	def count_to_bottom(xi, xf, y, bottom_y)
		rows = 0
		#rows += 1 while not (y = find_next_row(xi, xf, y)) > bottom_y
		while y < bottom_y
			y = find_next_row(xi, xf, y)
			rows += 1 if y != bottom_y
			#puts "ROW #{rows} Y #{y} BOTTOM #{bottom_y}"
		end
		rows
	end
	
	# Downwards Search
	# header: column to be evaluated
	# y: 'y' coordinate for this row
	# result: the header result for this 'y' coordinate
	# Progresively recognizes chars from line y between position.xi to
	# border.xf until border.xi to border.xf as follows
	#     2.3%¶ =>  2.3%
	#    ¶2.3%¶ =>  2.3%
	#   ¶¶2.3%¶ =>  2.3%
	#  1¶¶2.3%¶ => 12.3%
	# ¶1¶¶2.3%¶ => 12.3%
	def downwards_search(header, y, result)
		# Content line to be evaluated
		line = @content.lines[y]
		# Acceptable field to be recognized (E.j: +1,234,567.89)
		regex = result.regex
		# The right-most index where the field could be
		start = header.border.xf
		# The left-most index where only the field can be
		min = header.position.xi 
		# The left-most index where the field could be
		max = header.border.xi 
		# The index of the search
		counter = min
		# Amount of invalid iterations before giving up
		tolerance = 0
		# The last valid result recognized
		last_match = ""
		detected = false

		# Until tolerance is beaten or left-most border exceeded
		while tolerance <= Setup::Read.vertical_search_range and counter > header.border.xi 
			counter -= 1
			# Skip tolerance for right-side wildchars
			tolerance += 1 if detected
			# Evaluate with wildchars
			text = line[counter..start]
			# Evaluate without wildchars
			stripped_text = RegexHelper.strip_wildchar text
			if stripped_text != last_match 
				if stripped_text.match regex 
					detected = true
					tolerance = 0
					last_match = stripped_text
					# Record new MIN only if the result is relatively even (See center_mass)
					min = counter+1 if center_mass(text) > Setup::Read.center_mass_limit
					#puts "--------------------------------------------------------------------------------MIN #{min}"
					# Resets the max value
					max = header.border.xi
				else
					# Records max when the regex is lost because another format has been reached
					max = [counter+1, max].max
					#puts "--------------------------------------------------------------------------------MAX #{max}"
				end
			end
=begin
			puts "#{line[counter..start]} => #{last_match}----------------------------------------------------------CTR #{counter}"
			p_line = ""
			past_n = 0
			[max, min, start+1, start+1].each do |n|
				p_line << " "*(n - past_n -1) if n - past_n >= 1
				p_line << "|" if n != past_n
				past_n = n
			end
			puts line
			puts p_line
=end
			#puts "[#{y}] [#{max} (#{min}  #{start}) #{start}]"
		end
		if not last_match.nil? and last_match.match regex
			#puts "Last line eval: #{text} and #{last_match}"
			#puts "Final :: #{line[range[1]-counter..limit-1]} ||| #{line[limit..range[1]]}"
			
			result.result = last_match
		else
			result.result = Result::NOT_FOUND
		end
		# Even if the result wasn't found, set the new positions and borders
		# to recalculate for the next iteration
		result.position.xi = min
		result.edges.xi = max
		result.position.xf = RegexHelper.rindex(line[0..start])
		result.edges.xf = start
		result.position.y = y
		result.edges.y = y
	end

	# Center Mass
	# str: String to be evaluated
	# Calculates the mass center for the given string using 
	# weighted indexes as 1 => /¶/ ; 0 => /[^¶]/. The result
	# is a float between [0..1] inclusive with:
	# 1 => 1¶¶¶
	# 0.5 => ¶23¶
	# 0 => ¶¶¶4
	def center_mass str
		balance = 0.0
		skip = true
		index = 1.0
		count = 0.0
		last_index = index 
		str.chars.reverse_each do |c|
			if c != RegexHelper.wildchar
				balance += index
				count += 1
				skip = false
				last_index = index
			end
			index += 1 unless skip
		end
		n = count
		(balance/n)/(last_index + 1)
	end

	# Check Results
	# result: result being evaluated
	# result_n: result to be checked
	# Sets a limit between both results and moves it to the right
	# until both recognize a result and sets it.
	# Pre-Condition: result_n.result != Result::NOT_FOUND
	def check_result(result, result_n)
		line = @content.lines[result.position.y]
		limit = result.edges.xf
		while found = (result.result == Result::NOT_FOUND) and limit+1 < result_n.edges.xf
			limit += 1
			chunk = RegexHelper.strip_wildchar line[result.edges.xi..limit]
			chunk_n = RegexHelper.strip_wildchar line[limit+1..result_n.edges.xf]
			if chunk.match result.regex and chunk_n.match result_n.regex
				result_n.result = chunk_n
				result_n.edges.xi = limit + 1
				result_n.position.xi = RegexHelper.index(line[limit+1..result_n.edges.xf])
				result_n.position.xf = RegexHelper.rindex(line[limit+1..result_n.edges.xf])
				result.result = chunk
				result.edges.xf = limit
				result.position.xi = RegexHelper.index(line[result.edges.xi..limit])
				result.position.xf = RegexHelper.rindex(line[result.edges.xi..limit])
			end
			puts "#{line[result.edges.xi..result.edges.xf]}"
			puts "#{line[result_n.edges.xi..result_n.edges.xf]}"
		end
		return found
	end
end