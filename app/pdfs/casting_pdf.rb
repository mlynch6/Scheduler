class CastingPdf < Prawn::Document
	def initialize(season_piece, casts, castings, view)
		super()
		@season_piece = season_piece
		@casts = casts
		@castings = castings
		@view = view
		
		@num_casts_per_page = 4
		@table_font_size = 10
		
		repeat :all do
			set_header
			#set_footer
		end
		
		bounding_box([bounds.left, bounds.top - 30], :width  => bounds.width, :height => bounds.height - 40) do
			casting_table_per_page
		end
		
		set_footer
	end

	def set_header
		bounding_box [bounds.left, bounds.top], :width  => bounds.width, height: 30 do
			text "#{@season_piece.piece.name} Casting", size: 16, style: :bold
			text "As on #{Time.zone.today}", size: 8
		end
	end
	
	def set_footer
		options = {
			size: 8,
			align: :center,
			at: [bounds.left, bounds.bottom + 10],
			width: bounds.width
		}
		number_pages "Page <page> of <total>", options
	end
	
	def casting_table_per_page
		casts_per_pg = @casts.in_groups_of(@num_casts_per_page)
		i=1
		casts_per_pg.each do |casts_for_page|
			casting_table(casts_for_page)
			start_new_page if (i < casts_per_pg.length)
			i = i+1
		end
	end
	
	def casting_table(casts_for_table)
		casts_for_table = casts_for_table.delete_if { |elem| elem.nil? }
		col_widths = [140] + Array.new(casts_for_table.length, 100)
		data = cast_header(casts_for_table)+cast_rows(casts_for_table)
		
		table data do
			self.header = true
			self.column_widths = col_widths
			self.cell_style = { :size => @table_font_size, :border_color => "DDDDDD", :padding => 3 }
			row(0).font_style = :bold
			row(0).background_color = "DDDDDD"
		end
	end
	
	def cast_header(cast_names)
		[[""] + cast_names]
	end
	
	def cast_rows(casts_for_table)
		@castings.map do |character_name, casting_per_char|
			[character_name] + get_artist_names(casts_for_table, casting_per_char)
		end
	end
	
	def get_artist_names(casts, casting_per_char)
		casting_by_cast = casting_per_char.group_by(&:cast_name)
		casts.map do |cast_name|
			c = casting_by_cast[cast_name].first if casting_by_cast.has_key?(cast_name)
			if c && c.person then "#{c.person.last_name}, #{c.person.first_name[0]}." else "" end
		end
	end
end