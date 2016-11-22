=begin
=end
PDF::Reader::PageTextReceiver.class_eval do
	SPACE = " "

	def internal_show_text(string)
        if @state.current_font.nil?
          raise PDF::Reader::MalformedPDFError, "current font is invalid"
        end
        glyphs = @state.current_font.unpack(string)
        total_text = "" #EDIT
        total_width = 0 #EDIT
        newx, newy = @state.trm_transform(0,0)
        prev_space = false #EDIT
        glyphs.each_with_index do |glyph_code, index|
          # paint the current glyph
          utf8_chars = @state.current_font.to_utf8(glyph_code)

          # apply to glyph displacment for the current glyph so the next
          # glyph will appear in the correct position
          glyph_width = @state.current_font.glyph_width(glyph_code) / 1000.0
          th = 1
          total_width += glyph_width * @state.font_size * th #EDIT
          unless prev_space and utf8_chars == SPACE
          	total_text << utf8_chars #EDIT
          end
          prev_space = (utf8_chars == SPACE) #EDIT
          @state.process_glyph_displacement(glyph_width, 0, utf8_chars == SPACE)
        end
        @characters << PDF::Reader::TextRun.new(newx*2, newy*2, total_width, @state.font_size, total_text) #EDIT
    end

end
#=end




PDF::Reader::PageLayout.class_eval do
  def initialize(runs, mediabox)
      raise ArgumentError, "a mediabox must be provided" if mediabox.nil?

      @runs    = merge_runs(runs)
      @mean_font_size   = mean(@runs.map(&:font_size)) || 0
      @mean_glyph_width = mean(@runs.map(&:mean_character_width)) || 0
      @page_width  = (mediabox[2] - mediabox[0])*2 #EDIT
      @page_height = (mediabox[3] - mediabox[1])*2 #EDIT
      @x_offset = @runs.map(&:x).sort.first
      @current_platform_is_rbx_19 = RUBY_DESCRIPTION =~ /\Arubinius 2.0.0/ &&
                                      RUBY_VERSION >= "1.9.0"
    end

    def to_s
      return "" if @runs.empty?

      wildchar = Setup::Read.wildchar
      page = row_count.times.map { |i| wildchar * col_count }
      @runs.each do |run|
        x_pos = ((run.x - @x_offset) / col_multiplier).round
        y_pos = row_count - (run.y / row_multiplier).round
        if y_pos < row_count && y_pos >= 0 && x_pos < col_count && x_pos >= 0
          local_string_insert(page[y_pos], run.text, x_pos)
        end
      end
      interesting_rows(page).map(&:rstrip).join("\n")
    end

    private
=begin
    # given an array of strings, return a new array with empty rows from the
    # beginning and end removed.
    #
    #   interesting_rows([ "", "one", "two", "" ])
    #   => [ "one", "two" ]
    #
    def interesting_rows(rows)
      line_lengths = rows.map { |l| l.strip.length }

      return [] if line_lengths.all?(&:zero?)

      first_line_with_text = line_lengths.index { |l| l > 0 }
      last_line_with_text  = line_lengths.size - line_lengths.reverse.index { |l| l > 0 }
      interesting_line_count = last_line_with_text - first_line_with_text
      rows[first_line_with_text, interesting_line_count].map
    end

    def row_count
      @row_count ||= (@page_height / @mean_font_size).floor
    end

    def col_count
      @col_count ||= ((@page_width  / @mean_glyph_width) * 1.05).floor
    end

    def row_multiplier
      @row_multiplier ||= @page_height.to_f / row_count.to_f
    end

    def col_multiplier
      @col_multiplier ||= @page_width.to_f / col_count.to_f
    end

    def mean(collection)
      if collection.size == 0
        0
      else
        collection.inject(0) { |accum, v| accum + v} / collection.size.to_f
      end
    end

    def each_line(&block)
      @runs.sort.group_by { |run|
        run.y.to_i
      }.map { |y, collection|
        yield y, collection
      }
    end
=end
    # take a collection of TextRun objects and merge any that are in close
    # proximity
    def merge_runs(runs) #EDIT
      runs.group_by { |char|
        (char.y*100).to_i
      }.map { |y, chars|
        chars
        #group_chars_into_runs(chars.sort)
      }.flatten.sort
    end

=begin
    # This is a simple alternative to String#[]=. We can't use the string
    # method as it's buggy on rubinius 2.0rc1 (in 1.9 mode)
    #
    # See my bug report at https://github.com/rubinius/rubinius/issues/1985
    def local_string_insert(haystack, needle, index)
      if @current_platform_is_rbx_19
        char_count = needle.length
        haystack.replace(
          (haystack[0,index] || "") +
          needle +
          (haystack[index+char_count,500] || "")
        )
      else
        haystack[Range.new(index, index + needle.length - 1)] = String.new(needle)
      end
  end
=end
end
