class ScenePdf < Prawn::Document
	def initialize(piece, view)
		super()
		@piece = piece
		@view = view
		piece_title
		scenes_table
	end
	
	def piece_title
		text @piece.name, size: 16, style: :bold
		text "Scene by scene", size: 12
		move_down 20
	end
	
	def scenes_table
		table scene_header+scene_rows do
			self.header = true
			self.column_widths = [190, 310, 40]
			self.cell_style = { :size => 10, :border_color => "AAAAAA" }
			row(0).font_style = :bold
			columns(2).align = :center
		end
	end
	
	def scene_header
		[["Scenes", "Characters", "Track"]]
	end
	
	def scene_rows
		@piece.scenes.map do |scene|
			[scene.name, scene.characters.map { |char| char.name }.join(", "), scene.track]
		end
	end
end