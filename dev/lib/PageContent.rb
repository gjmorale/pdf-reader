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

	def find_text text, offset = nil
		offset ||= 0
		@content.lines[offset..-1].each do |line|
			line = RegexHelper.strip_wildchar(line)
			line.match(text) do |m|
				return line[m.offset(0)[0]..m.offset(0)[1]-1]
			end
		end
		return false
	end

	# Looks for the first match of the field regex in
	# the page from offset to bottom.
	# The field width must be at least as big as the field.
	# Once the field is found, it sets it's position and
	# width if it's multiline
	def search_next(field, offset, from = nil, to = nil)
		#puts "LOOKING FOR #{field} as #{field.regex} #{from}" if Setup::Debug.overview
		xi = 0
		matched = false
		from = from ? from : 0
		to = to ? (from+to) : -1
		@content.lines[offset..@content.lines.size-field.width].each.with_index do |line, y_full|
			y = offset + y_full
			if field.width > 1
				line = Multiline.generate @content.lines[y, field.width]
			end
			line[from..to].match(field.regex){|m|
				xi = from + m.offset(0)[0]
				#TODO: change field.text.length for the striped text found to make text_expand compatible with multiple-regex field.text E.j: Field.new("[GESTIONADO|MANDATO]")
				xf = (from + m.offset(0)[1] + field.text.length*Setup::Read.text_expand).to_i
				if m.is_a? MultiMatchData
					width = (field.is_a? SingleField and field.enforced_width) ? field.width : m.offset[3]-m.offset[2]+1
					if field.orientation > 7 or field.orientation < 3
						top_y = y + m.offset[2] - 1
					elsif field.orientation < 7 and field.orientation > 3
						top_y = y + m.offset[3] - (width)
					else
						top_y = y + (m.offset[2] + m.offset[3] - width)/2
					end
					field.position = TextNode.new(xi, xf-1, top_y+1) 
					field.width = width 
				else
					field.position = TextNode.new(xi, xf-1, y) 
				end
				matched = true
			}
			break if matched
		end
		if matched
			scope = field.width > 1 ? @content.lines[field.top, field.width] : @content.lines[field.top]
			text = Multiline.generate scope
			index = field.right
			while index > field.left
				index -= 1
				text[index..field.right].match(field.regex) do |m|
					field.left = index + m.offset(0)[0]
					field.right = field.right
					return true
				end
			end
			return true
		else
			return false
		end
	end

	# Calls a horizontal_search to the right until every result
	# for the field is is found. for every result found the
	# starting index to search is updated.
	def find_results_right(field)
		range = [field.left, field.right+1, field.top, field.width]
		field.results.each.with_index do |result, i|
			regex = result.regex
			new_limit = horizontal_search result, range, regex
			if result.result != Result::NOT_FOUND
				range[1] = new_limit
			end
		end
	end
	
	# Searches the line(s) from the last right index to further
	# to the right until the last match right index has been passed
	# horizontal_search_range times. Then it takes the last match
	# and assigns it with position to the result.
	def horizontal_search(result, range, regex)
		#puts "#{range}"
		counter = 0
		tolerance = 0
		last_match = ""
		detected = false
		limit = range[1]
		while tolerance <= Setup::Read.horizontal_search_range and range[1] + counter < line_size
			counter += 1
			tolerance += 1 if detected
			lines = (range[3] > 1 ? (range[2]..range[2]+range[3]-1) : range[2] )
			text = (Multiline.generate @content.lines[lines])[range[1]..range[1]+counter]
			text = RegexHelper.strip_wildchar(text)
			if text.match regex
				detected = true
				if text.is_a? Multiline
					m_scope = text.multi_match regex
					scope ||= m_scope
					m_scope.size do |i|
						scope[i] = true if m_scope[i] and not scope[i]
						detected = false if scope[i] and not m_scope[i]
					end
				end
				if detected
					tolerance = 0 if text != last_match
					last_match = text
					limit = range[1] + counter
				end
			end
		end
		if Setup::Debug.overview	#DEBUG ONLY
			#lines = (range[3] > 1 ? (range[2]..range[2]+range[3]-1) : range[2] )
			#text = (Multiline.generate @content.lines[lines])[range[1]..range[1]+counter] 
			#puts "#{RegexHelper.strip_wildchar(text).to_s}<<"		
		end										
		if not last_match.nil? and last_match.match regex
			result.result = last_match
		else
			result.result = Result::NOT_FOUND
		end
		return limit
	end

	def clean range, regex
		@content = @content.each_line.with_index.map{|line, i|
			if i >= range[2] and i <= range[3]
				stripped = RegexHelper.strip_wildchar line[range[0]..range[1]]
				if stripped.match regex
					line[range[0]..range[1]] = Setup::Read.wildchar*(range[1]-range[0])
				end
			end
			line
			}.join
	end

	# Get Row
	# xi, xf, y: dimensions of the table header to be evalueated
	# The algorithm starts on the line 'y' and adds the next line downwards 
	# until the format is found. There is a risk of crashing with neigbour
	# results. in that case choose an other guide column
	def get_row(table_range, guide, skip_regex = nil)
		xi = guide.outer_left
		xf = guide.outer_right
		yi = table_range[2]
		yf = table_range[3]
		index = 0
		regex = Setup.inst.get_regex(guide.type, false)
		#puts "Looking for a row #{yf-index} >= #{yi} in #{xi} - #{xf} = #{xf-xi} (#{@number})"
		while yf - index >= yi
			#puts "#{yf} - #{index} >= #{yi}"
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

	def get_chunk xi,xf,yi,yf
		lines = (Multiline.generate @content.lines[yi..yf])
		text = lines[xi..xf]
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
	def search_results_left(range, row, result)
		#puts "Searching"
		return true if range[2] > range[3]
		# Content line to be evaluated
		line = Multiline.generate(@content.lines[row.yi..row.yf])
		# Acceptable field to be recognized (E.j: +1,234,567.89)
		regex = result.regex
		# The right-most index where the field could be
		start = range[3]
		# The left-most index where only the field can be
		min = range[1] + 1
		# The left-most index where the field could be
		max = range[0] 
		# The index of the search
		counter = min
		# Amount of invalid iterations before giving up
		tolerance = 0
		# The last valid result recognized
		last_match = ""
		detected = false
		# Until tolerance is beaten or left-most border exceeded
		while tolerance <= Setup::Read.vertical_search_range and counter > range[0] 
			counter -= 1
			# Skip tolerance for right-side wildchars
			tolerance += 1 if detected
			# Evaluate with wildchars
			text = line[counter..start]
			# Evaluate without wildchars
			stripped_text = RegexHelper.strip_wildchar text

			if stripped_text != last_match 
				#puts "#{text}" if stripped_text and counter > 230
				if stripped_text.match regex 
					detected = true
					tolerance = 0
					last_match = stripped_text
					# min is the posible new left for result
					min = counter #if center_mass(text) < 0.5
					# Resets the max value because format has been recovered
					max = range[0]
				else
					# Records max when the regex is lost because another format has been reached
					max = [counter+1, max].max
				end
			end
		end
		regex = regex[0] if not last_match.is_a? Multiline and regex.is_a? Array
		if not last_match.nil? and last_match.match regex
			result.result = last_match
			result.left = min
			result.edges.xi = max
			right_limit = RegexHelper.rindex(line[counter..start]) || 0
			result.right = counter + right_limit
			result.edges.xf = start
			result.position.y = row.yi
			result.edges.y = row.yf
			return true
		else
			result.result = Result::NOT_FOUND
			return false
		end
	end

	# Center Mass
	# str: String to be evaluated
	# Calculates the mass center for the given string using 
	# weighted indexes as 1 => /¶/ ; 0 => /[^¶]/. The result
	# is a float between [0..1] inclusive with:
	# 1 	=> 1¶¶¶
	# 0.5 	=> ¶23¶
	# 0 	=> ¶¶¶4
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
	# result: left result
	# result_n: right result
	# Sets a limit between both results and moves it to the right
	# until both recognize a result and sets it.
	# Pre-Condition: result_n.result != Result::NOT_FOUND
	def check_result(row, result, result_n)
		line = Multiline.generate @content.lines[row.yi..row.yf]
		if result.right >= result_n.left #Overstepping
			limit = result_n.left
			solved = false
			while limit <= result.outer_right
				left = RegexHelper.strip_wildchar line[result.left..limit-1]
				right = RegexHelper.strip_wildchar line[limit..result_n.right]
				if left.match(result.regex) and right.match(result_n.regex)
					result.right = limit -1
					result_n.left = limit
					result.result = left
					result_n.result = right
					solved = true
					break
				else
					limit += 1
				end 
			end
			unless solved
				result_n.left = result.right + 1
				result_n.result = Result::NOT_FOUND
			end
		end

		if result.result == Result::NOT_FOUND
			range = (result_n.left-1 - result.edges.xi)
			return false if range <= 0
			#puts "RANGE LEFT: #{result} #{result.edges.xi}  to  #{result_n.left-1}"
			#puts line[result.edges.xi .. result_n.left-1]
			range.times do |i|
				text = RegexHelper.strip_wildchar(line[result_n.left - 2 - i .. result_n.left - 1])
				#puts text.strings if not text.empty?
				if text != result.result and text.match result.regex
					result.result = text
					result.left = result_n.left - 2 - i
				end
			end
			return (result.result != Result::NOT_FOUND)
		end
	end

	def print range, offset, start, show
		top = offset - range
		bottom = range + offset
		top = 0 if top < 0
		bottom = @line_height - 1 unless bottom < @line_height
		start = @line_size - show - 1 unless start < @line_size - show
		@content.lines[top..bottom].each.with_index do |line, i|
			prefix = i == range ? ">" : " "
			puts "#{prefix}#{line[start,show]}"
		end 
	end

end