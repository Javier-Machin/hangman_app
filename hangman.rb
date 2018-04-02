require "json"
require "sinatra"
require "sinatra/reloader" if development?

class Hangman

  def initialize
    @secret_word = select_word
    @display_content = "_" * @secret_word.length
    @failed_attemps = 0
  end

  def main_menu
    option = "3"
    until option == "1" || option == "2"
      puts "(1) New game"
      puts "(2) Load game"
      print "Play new game or load the saved game? "
      option = gets.chomp[0]
      if option == "2" 
        if File.exist?("saved_state.json")
          load_state
        else
          puts "There is no saved game, save one first"
          option = "3"
        end
      end
    end
    start_game
  end

  private

  def save_state
    json_object = { :secret_word => @secret_word, :display_content => @display_content,
    	              :failed_attemps => @failed_attemps }.to_json
    File.open("saved_state.json", "w") { |file| file.write(json_object) }
  end

  def load_state
    save_file = File.read("saved_state.json")
    json_hash = JSON.parse(save_file)
    @secret_word = json_hash["secret_word"]
    @display_content = json_hash["display_content"]
    @failed_attemps = json_hash["failed_attemps"]
  end
  
  def start_game
    player_won = false
    while @failed_attemps != 10 
      puts @display_content
      puts "#{10 - @failed_attemps.to_i} turns left" 
      print "Enter a letter or attempt the full word: "
      letters = gets.chomp
      if letters == "save"
        save_state
        next
      end
      break if letters == "exit"
      update_display(letters) if letters
      player_won = player_won?
      break if player_won
    end
    puts "Game over, the secret word was: #{@secret_word}" if @failed_attemps == 10
  end

  def select_word
    words = File.readlines("5desk.txt").select { |word| word.length.between?(5, 12) }
    words[rand(words.length)].strip
  end

  def update_display(letters)
    letters.downcase!
    current_state = "#{@display_content}"
    if letters.length == 1
      @display_content.length.times do |index|
        @display_content[index] = letters if @secret_word[index].downcase == letters
      end
    else
      @display_content = letters if letters == @secret_word.downcase
    end

    current_state == @display_content ? print_toon(1) : print_toon(0)
  end

  def player_won?
    unless @display_content.include?("_")
      puts "You found the correct word!"
      true
    end
  end

  def print_toon(increment)
    @failed_attemps += increment

    case @failed_attemps
    when 0
      puts "  ______"
      puts "        |"
      puts "        |"
      puts "        |"
      puts "        |"
    when 1
      puts "  ______"
      puts " |      |"
      puts "        |"
      puts "        |"
      puts "        |"
    when 2
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts "        |"
      puts "        |"
    when 3
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts " |      |"
      puts "        |"
    when 4
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts " ||     |"
      puts "        |"  
    when 5
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts "/||     |"
      puts "        |"
    when 6
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts "/||\\    |"
      puts "        |"
    when 7
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts "/||\\    |"
      puts "/       |"
    when 8
      puts "  ______"
      puts " |      |"
      puts "(oo)    |"
      puts "/||\\    |"
      puts "/  \\    |"
    when 9
      puts "  ______"
      puts " |      |"
      puts "(ox)    |"
      puts "/||\\    |"
      puts "/  \\    |"  
    when 10
      puts "  ______"
      puts " |      |"
      puts "(xx)    |"
      puts "/||\\    |"
      puts "/  \\    |"           
    end
    puts ""
  end

end

my_game = Hangman.new
my_game.main_menu
#We will need to butcher the main loop and the main menu probably, so be it 
get '/' do
  #message = CaesarCypher.create_message(params)
  #erb :index, :locals => {:message => message} 
end
