class PageContent

	attr_reader :line_size
	attr_reader :line_height
	attr_reader :number

	# Creates a PageContent object from content
	# as a string and a page_number
	def initialize(page_number, content)
		@number = page_number
		@content = content
		@line_size = @content.lines[0].length
		@line_height = @content.lines.size
	end 

	def to_s
		@content
	end

	# Looks for the first match of the field regex in
	# the page from offset to bottom.
	# The field width must be at least as big as the field.
	# Once the field is found, it sets it's position and
	# width if it's multiline
	def search_next(field, offset)
		xi = 0
		@content.lines[offset..@content.lines.size-field.width].each.with_index do |line, y_full|
			y = offset + y_full
			if field.width > 1
				line = Multiline.generate @content.lines[y, field.width]
			end
			line.match(field.regex){|m|
				xi = m.offset(0)[0]
				xf = m.offset(0)[1]
				field.position = TextNode.new(xi, xf-1, y) 
				field.width = m.width if m.is_a? MultiMatchData
				return true
			}
		end 
		return false
	end

	# Calls a horizontal_search to the right until every result
	# for the field is is found. for every result found the
	# starting index to search is updated.
	def find_results_right(field)
		range = [field.left, field.right+1, field.top, field.width]
		field.results.each.with_index do |result, i|
			regex = result.regex
			range[1] = horizontal_search result, range, regex
		end
	end
	
	# Searches the line(s) from the last right index to further
	# to the right until the last match right index has been passed
	# horizontal_search_range times. Then it takes the last match
	# and assigns it with position to the result.
	def horizontal_search(result, range, regex)
		counter = 0
		tolerance = 0
		last_match = ""
		detected = false
		limit = range[1]
		while tolerance <= Setup::Read.horizontal_search_range and range[1] + counter < line_size
			counter += 1
			tolerance += 1 if detected
			lines = (range[3] > 1 ? (range[2]..range[2]+range[3]-1) : range[2] )
			lines = range[2]
			text = (Multiline.generate @content.lines[lines])[range[1]..range[1]+counter]
			text = RegexHelper.strip_wildchar(text)
			if text.match regex
				detected = true
				tolerance = 0
				last_match = text
				limit = range[1] + counter
			end
		end
		if not last_match.nil? and last_match.match regex
			result.result = last_match
		else
			result.result = Result::NOT_FOUND
		end
		return limit
	end

	# Get Row
	# xi, xf, y: dimensions of the table header to be evalueated
	# The algorithm starts on the line 'y' and adds the next line downwards 
	# until the format is found. There is a risk of crashing with neigbour
	# results. in that case choose an other guide column
	def get_row(range, guide)
		xi = guide.outer_left
		xf = guide.outer_right
		yi = range[2]
		yf = range[3]
		index = 0
		regex = Setup.bank.get_regex(guide.type, false)
		while yf - index >= yi
			range = (index == 0 ? yf : (yf - index..yf))
			text = Multiline.generate @content.lines[range]
			text = text[xi..xf]
			text = RegexHelper.strip_wildchar text
			if text.match regex
				return yf - index
			end
			index += 1
		end
		return nil
	end

	# Vertical Search
	# rows: the rows to be recognized
	# header: The header of the column to be recognized
	# Vertical search goes row by row looking for results
	# for the header. The header results must exist
	# initialy and have the same dimensions as the header.
	# For each iteration the headers position and border 
	# is recalculated. This way the information of every
	# result makes the search for the others more accurate.
	def vertical_search(rows, header)
		done = false
		while not done
			done = true
			rows.each.with_index do |row, i|
				search_results_left(header, row, header.results[i])
				#header.recalculate_position
			end
		end
	end
	
	# Search Results Left
	# header: column to be evaluated
	# row: row being evaluated
	# result: the header result for this row
	# Progresively recognizes chars from lines in row between position.xi(left) and
	# border.xf(outer right) until border.xi(outer_left) and border.xf(outer_right) as follows
	#     2.3%¶ =>  2.3%
	#    ¶2.3%¶ =>  2.3%
	#   ¶¶2.3%¶ =>  2.3%
	#  1¶¶2.3%¶ => 12.3%
	# ¶1¶¶2.3%¶ => 12.3%
	def search_results_left(header, row, result)
		# Content line to be evaluated
		line = Multiline.generate(@content.lines[row.yi..row.yf])
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
					# min is the posible new left for result
					#puts "#{center_mass(text)} < #{Setup::Read.center_mass_limit}"
					min = counter #if center_mass(text) < 0.5
					# Resets the max value because format has been recovered
					max = header.border.xi
				else
					# Records max when the regex is lost because another format has been reached
					max = [counter+1, max].max
				end
			end
		end
		if not last_match.nil? and last_match.match regex
			result.result = last_match
			result.position.xi = min
			result.edges.xi = max
			result.position.xf = RegexHelper.rindex(line[0..start])
			result.edges.xf = start
			result.position.y = row.yi
			result.edges.y = row.yf
		else
			result.result = Result::NOT_FOUND
		end
		# Even if the result wasn't found, set the new positions and borders
		# to recalculate for the next iteration
		return result.result == Result::NOT_FOUND
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
		if str.is_a? Multiline
			mean = 0.0
			n = 0.0
			str.strings.each do |s|
				unless (x = center_mass s).nan?
					n += 1.0
					mean += x
				end
			end
			return mean/n
		end
		balance = 0.0
		skip = true
		index = 1.0
		count = 0.0
		last_index = index 
		str.chars.reverse_each do |c|
			if c != RegexHelper.wildchar
				balance += index
				count += 1.0
				skip = false
				last_index = index
			end
			index += 1.0 unless skip
		end
		n = count
		#puts "#{(balance/n)}/#{(last_index + 1.0)}"
		(balance/n)/(last_index + 1.0)
	end

	# Check Results
	# result: result being evaluated
	# result_n: result to be checked
	# Sets a limit between both results and moves it to the right
	# until both recognize a result and sets it.
=begin
	# Pre-Condition: result_n.result != Result::NOT_FOUND
	def check_result(result, result_n)
		line = @content.lines[result.position.y]
		limit = result.edges.xf
		found = false
		while not found = (result.border.xf+1 == result_n.border.xi)
			limit += 1
			chunk = RegexHelper.strip_wildchar line[result.edges.xi..limit]
			chunk_n = RegexHelper.strip_wildchar line[limit+1..result_n.edges.xf]
			if chunk.match result.regex and chunk_n.match result_n.regex
				result_n.result = chunk_n
				result_n.edges.xi = limit + 1
				result_n.position.xi = limit + 1 + RegexHelper.index(line[limit+1..result_n.edges.xf])
				result_n.position.xf = limit + 1 + RegexHelper.rindex(line[limit+1..result_n.edges.xf])
				result.result = chunk
				result.edges.xf = limit
				result.position.xi = result.edges.xi + RegexHelper.index(line[result.edges.xi..limit])
				result.position.xf = result.edges.xi + RegexHelper.rindex(line[result.edges.xi..limit])
			end
			puts "#{line[result.edges.xi..result.edges.xf]}"
			puts "#{line[result_n.edges.xi..result_n.edges.xf]}"
			puts line
		end
		return found
	end
=end

	# Check Results
	# result: result being evaluated
	# result_n: result to be checked
	# Sets a limit between both results and moves it to the right
	# until both recognize a result and sets it.
	# Pre-Condition: result_n.result != Result::NOT_FOUND
	def check_result(row, result, result_n)
		line = Multiline.generate @content.lines[row.yi..row.yf]
		if result.right >= result_n.edges.xi
			new_edge = result.right + 1
			result_n.edges.xi = new_edge
			new_result = line[new_edge..result_n.right]
			result_n.result = RegexHelper.strip_wildchar new_result
			result_n.left = RegexHelper.index new_result
			return true
		end

		if result_n.result == Result::NOT_FOUND
			range = (result_n.edges.xf - result.right - 1)
			return false if range <= 0
			#puts "RANGE RIGHT: #{result_n} #{result.right}  to  #{result_n.edges.xf}"
			#puts line[result.right .. result_n.edges.xf]
			last_text = ""
			range.times do |i|
				text = RegexHelper.strip_wildchar(line[result_n.edges.xf - i .. result_n.edges.xf])
				if text != last_text and text.match result.regex
					last_text = text
					result_n.result = text
					result_n.left = result_n.edges.xf - i
				end
			end
		end

		if result.result == Result::NOT_FOUND
			range = (result_n.left-1 - result.edges.xi)
			return false if range <= 0
			#puts "RANGE LEFT: #{result} #{result.edges.xi}  to  #{result_n.left-1}"
			#puts line[result.edges.xi .. result_n.left-1]
			last_text = ""
			range.times do |i|
				text = RegexHelper.strip_wildchar(line[result_n.left - 1 - i .. result_n.left - 1])
				#puts text.strings if not text.empty?
				if text != last_text and text.match result.regex
					last_text = text
					#puts "SETTED!!"
					result.result = text
					result.left = result_n.left - 1 - i
				end
			end
		end
	end

end