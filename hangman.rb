class Game
    POSSIBLE_LETTERS = ("a".."z").to_a
    MAX_WRONG_GUESSES = 10
  
    def initialize
      @word_to_guess = filtered_words.sample
      @guesses_remaining = MAX_WRONG_GUESSES
      @guessed_letters = []
      @wrong_guesses = []
      @attempted_words = []
    end

    def start_game
      until game_over?
        display_status
        enter_guess
      end
  
      conclude_game
    end
  
    private
  
    def filtered_words
        file_path = "google-10000-english-no-swears.txt"
        words = File.readlines(file_path).map { |line| line.chomp.downcase.strip }
        filtered_words = words.filter {|word| word.length.between?(5,12)}
        filtered_words
    end
  
    def display_status
      puts "\nGuesses remaining: #{@guesses_remaining}"
      puts "Guessed letters: #{@guessed_letters.join(", ")}"
      puts "Non-Guessed letters: #{@wrong_guesses.join(", ")}"
      puts "Attempted words: #{@attempted_words.join(", ")}"
      Feedback.give_feedback(@guessed_letters, @word_to_guess)
    end
  
    def enter_guess
        print "\nYour guess (letter or word), or type 'save' to save your game: "
        guess = gets.chomp.downcase.strip
      
        if guess == "save"
          save_game
          puts 'Game saved successfully. Exiting game...'
          exit
        end
      
        until valid_guess?(guess) || guess == "save"
          print "Invalid guess. Try again: "
          guess = gets.chomp.downcase.strip
        end
      
        process_guess(guess) unless guess == "save"
    end

    def save_game
        Dir.mkdir('saves') unless Dir.exist?('saves')
        filename = "saves/saved_game_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.dat"
        File.open(filename, 'wb') do |file|
          file.write(Marshal.dump(self))
        end
    end

    def self.load_game
        unless Dir.exist?('saves')
          puts 'No saved games found.'
          return nil
        end
      
        saved_games = Dir.glob('saves/*').select { |filename| File.file?(filename) }
        if saved_games.empty?
          puts 'No saved games found.'
          return nil
        end
      
        puts "Select a saved game to load:"
        saved_games.each_with_index do |game, index|
          puts "#{index + 1}: #{game}"
        end
        choice = gets.chomp.to_i
        filename = saved_games[choice - 1]
      
        content = File.read(filename)
        loaded_game = Marshal.load(content)
        File.delete(filename) # Optionally delete the save file after loading
        loaded_game
      end
      
  
    def valid_guess?(guess)
      return false if guess.empty?
      return true if guess.length == 1 && POSSIBLE_LETTERS.include?(guess) && !@guessed_letters.include?(guess) && !@wrong_guesses.include?(guess)
      return true if guess.length > 1 && !@attempted_words.include?(guess)
      false
    end
  
    def process_guess(guess)
      if guess.length == 1
        if @word_to_guess.include?(guess)
          @guessed_letters << guess
        else
          @wrong_guesses << guess
          @guesses_remaining -= 1
        end
      else
        @attempted_words << guess
        if guess == @word_to_guess
          @guessed_letters = @word_to_guess.chars.uniq
        else
          @guesses_remaining -= 2
        end
      end
    end
  
    def game_over?
      @guesses_remaining <= 0 || word_guessed?
    end
  
    def word_guessed?
      @word_to_guess.chars.all? { |letter| @guessed_letters.include?(letter) }
    end
  
    def conclude_game
      if word_guessed?
        puts "\nCongratulations! You've guessed the word: #{@word_to_guess}"
      else
        puts "\nOut of guesses. The word was: #{@word_to_guess}. Better luck next time!"
      end
    end
  end
  
  class Feedback
    def self.give_feedback(guessed_letters, word_to_guess)
      feedback = word_to_guess.chars.map { |char| guessed_letters.include?(char) ? char : "-" }.join
      puts "\nWord: #{feedback}"
    end
  end
  
puts "Welcome to Hangman!"
choice = nil

until choice == 1 || choice == 2
  puts "1. Start a new game"
  puts "2. Load a saved game"
  choice = gets.chomp.to_i

  if choice == 1
    game = Game.new
    game.start_game
  elsif choice == 2
    game = Game.load_game
    game.start_game unless game.nil?
  else
    puts "Invalid option. Please enter 1 or 2."
  end
end