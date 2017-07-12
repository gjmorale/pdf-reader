PDF::Reader::PageState.class_eval do

  def tilted?
    trm = text_rendering_matrix
    return true if trm.b !=0 or trm.c != 0
    #puts "---------\n#{ctm.a},#{ctm.b}"
    #puts "#{ctm.c},#{ctm.d}"
    #puts "#{ctm.e},#{ctm.f}"
  end

end

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
        unless @state.tilted? #or total_text = ' '#string.match /^\d{6}\s[A-Z0-9]{8}\s\d{6}$/ #Morgan Stanley vertical code removerz
          @characters << PDF::Reader::TextRun.new(newx*2, newy*2, total_width, @state.font_size, total_text) #EDIT
        end
    end

end

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

      wildchar = '¶'
      #@mean_glyph_width = @page_width if @mean_glyph_width.nan?
      page = row_count.times.map { |i| wildchar * col_count }
      @runs.each do |run|
        x_pos = ((run.x - @x_offset) / col_multiplier).round
        y_pos = row_count - (run.y / row_multiplier).round
        if y_pos < row_count && y_pos >= 0 && x_pos < col_count && x_pos >= 0
          local_string_insert(page[y_pos], run.text.gsub("\n",''), x_pos)
        end
      end
      interesting_rows(page).map(&:rstrip).join("\n")
    end

    def mean(collection)
      if collection.size == 0
        0
      else
        if collection.first.is_a? Float
          total = collection.inject(0) do |accum, v|
            unless v.nil? or v.nan?
              accum + v
            else
              accum
            end
          end
          nans = collection.inject(0) do |accum, v|
            if v.nil? or v.nan?
              accum + 1
            else
              accum
            end
          end
          nans = nans.nil? ? 0 : nans
          total / (collection.size.to_f - nans)
        else
          collection.inject(0) { |accum, v| accum + v} / collection.size.to_f
        end
      end
    end

    private

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



    # This is a simple alternative to String#[]=. We can't use the string
    # method as it's buggy on rubinius 2.0rc1 (in 1.9 mode)
    #
    # See my bug report at https://github.com/rubinius/rubinius/issues/1985
    def local_string_insert(haystack, needle, index)
      #return if needle == ' '
      if @current_platform_is_rbx_19
        char_count = needle.length
        haystack.replace(
          (haystack[0,index] || "") +
          needle +
          (haystack[index+char_count,500] || "")
        )
      else
        needle.each_char.with_index do |c,i|
          if haystack[index+i] == '¶'
            haystack[index+i] = needle[i]
          elsif haystack[index+i] == ' '
            haystack[index+i] = needle[i]
          elsif needle[i] == ' '
          elsif index+i > 0 and haystack[index+i-1] == '¶'
            haystack[index+i-1] = haystack[index+i]
            haystack[index+i] = needle[i]        
          elsif index+i+needle.length < haystack.length and haystack[index+needle.length] == '¶'
            haystack[index+i+needle.length] = needle[i]
          end
        end
      end
    end
end
