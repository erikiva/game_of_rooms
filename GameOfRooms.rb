require 'json'

class Space

	attr_accessor :name, :description, :objects, :exits

	def initialize(name, description, exits, objects=[])
		@name = name
		@description = description
		@objects = objects
		@exits = exits
	end

	def release_object object
		@objects.delete(object)  
	end

	def recover_object object
		@objects << object
	end

	def show_info
		puts "You have entered #{@description}"
		if @objects.length > 0 
			@objects.each {|object| puts "You can see a #{object}"}
		end 
		print "Exits: "
		@exits.each do |orientation, exit|
			print " #{orientation.to_s.upcase}" if exit 
		end
	end

end

class Character
	attr_accessor :inventory, :current_space
	def initialize
		@inventory = []
		@current_space  = nil
	end
	def get_inventory
		if @inventory.length > 0
			puts "You have:"
			@inventory.each {|item| puts "- A #{item}"}
		else 
			puts "You have nothing"
		end
	end

	def pick_object object
		@inventory << object
	end
	def drop_object object
		@inventory.delete(object) 
	end
end

class Game 
	attr_accessor :user_answer
	def initialize 
		@spaces = {}
		@user_answer = 0
		@character = add_character
	end

	def add_character
		@character = Character.new
	end

	def add_space name, description, exits, objects=[]
		space = Space.new(name, description, exits, objects)
		@spaces[name] = space
	end

	# def connect_spaces space1, direction1, space2, direction2
	# 	space1[:direction1] = space2
	# 	space2[:direction2] = space1
	# end

	

	def move direction
		if @character.current_space 
			if @spaces[@character.current_space].exits[direction] == :exit
				puts "Congratulations, you've won the game"
				@user_answer = false
			else 
				enter_space @spaces[@character.current_space].exits[direction]
			end
		end
	end

	def enter_space space_name
		
		@character.current_space = space_name
		space = @spaces[space_name]
		space.show_info
	end

	def character_pick_object object 	
		obj = @spaces[@character.current_space].release_object object
		if obj
			@character.pick_object obj
			puts "You pick up a #{obj}"
		else
			puts "There's no #{object} here"
		end
	end
		
	def character_drop_object object
		obj = @character.drop_object object
		if obj
			@spaces[@character.current_space].recover_object obj
			puts "You dropped up a #{obj}"
		else
			puts "You don't have a #{object} to drop"
		end

	end

	def save_game
		contents = @spaces, @character.inventory, @character.current_space
		IO.write(savegame.txt, contents)
	end

	def load_game
		contents  = File.open('savegame.txt') do|file| Marshal.load(file) end
		
		puts contents
	end


	def setup_game 
		add_space :big_room, "a big dark room", {:n=>nil, :s=>:green_forest, :e=>nil, :o=>nil}, ["sword"]
		add_space :green_forest, "a green forest", {:n=>:big_room, :s=>:lake, :e=>nil, :o=>:humid_dungeon}, ["helmet"]
		add_space :humid_dungeon, "a cold and humid dungeon", {:n=>nil, :s=>nil, :e=>:green_forest, :o=>nil}
		add_space :lake, "a snake infested lake", {:n=>:green_forest, :s=>nil, :e=>:mountain, :o=>nil}
		add_space :mountain, "a mountain", {:n=>nil, :s=>:exit, :e=>nil, :o=>:lake}
		puts "You have entered our world, follow the instructions to advance or type Q to exit"
		enter_space :big_room

	end

	def start
		setup_game
		while @user_answer
			print "\n> " 
			@user_answer = gets.chomp.downcase
			if @spaces[@character.current_space].exits[@user_answer.to_sym] 
				move @user_answer.to_sym
			elsif @user_answer.downcase.include? "pick up"
				character_pick_object user_answer.split.last.downcase
			elsif @user_answer.downcase.include? "drop"
				character_drop_object user_answer.split.last.downcase
			elsif
				@user_answer.downcase.include? "inventory"
				@character.get_inventory
			elsif @user_answer.to_sym == :q
				puts "Good Bye!"
				@user_answer = false
			else
				puts "I don't know what you mean."
				@spaces[@character.current_space].show_info
			end
		end

	end

	def new_game
		setup_game
		start
	end
end

game = Game.new
game.start	
