require "sinatra"
require "sinatra/reloader" if development?

configure do
  enable :sessions
  set :session_secret, "secret"
end

class Hangman

  attr_accessor :display_content

  def initialize
    @secret_word = select_word
    @display_content = "_" * @secret_word.length
    @failed_attemps = 0
  end

  def make_guess(params)
    if params["string"] != nil
      toon = update_display(params["string"])
      if player_won? != nil 
        @display_content = player_won? + "#{@secret_word}.\n" +
                                         "Enter a letter to guess another word"   
      end
      toon      
    end
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
    if !@display_content.include?("_")
      "You found the correct word! " 
    elsif @failed_attemps == 10
      "You lost! The word was: "  
    end
  end

  def print_toon(increment)
    @failed_attemps += increment

    case @failed_attemps

    when 0 
      ["|","","","",""]
    when 1
      ["|"," |","","",""] 
    when 2
      ["|", " |","(oo)","",""] 
    when 3
      ["|"," |","(oo)"," |",""] 
    when 4
      ["|"," |","(oo)"," ||",""]  
    when 5
      ["|"," |","(oo)","/||",""]
    when 6
      ["|"," |","(oo)","/||\\",""] 
    when 7
      ["|"," |","(oo)","/||\\","/"]
    when 8
      ["|"," |","(oo)","/||\\","/  \\"]
    when 9
      ["|"," |","(ox)","/||\\","/  \\"]  
    when 10
      ["|"," |","(xx)","/||\\","/  \\"]          
    end
    
  end

  def set_new_session(session)
    session[:secret_word] = @secret_word
    session[:failed_attemps] = @failed_attemps
    session[:display_content] = @display_content
    session
  end

  def set_current_session(session)
    @secret_word = session["secret_word"]
    @failed_attemps = session["failed_attemps"]
    @display_content = session["display_content"]
  end

end

get '/' do 
  erb :index   
end

get '/start' do
  my_game = Hangman.new 
  @session = session 
  session = my_game.set_new_session(@session)
  session["length"] = "Number of letters: #{session["secret_word"].length}"
  redirect 'play'
end

get '/play' do
  my_game = Hangman.new
  @session = session
  my_game.set_current_session(@session)
  redirect 'start' if my_game.player_won? != nil 
  toon = my_game.make_guess(params)
  @session = session 
  session = my_game.set_new_session(@session) 
  erb :play, :locals => {:display => my_game.display_content, 
                         :toon => toon, :length => session["length"]}
end 
