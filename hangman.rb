class Game
    def initialize
        @word_to_guess = filtered_words.sample
        @guesses_remaining = 10
    end

    def filtered_words
        file_path = "google-10000-english-no-swears.txt"
        words = File.readlines(file_path)
        filtered_words = words.filter {|word| word.length.between?(5,12)}
        filtered_words
    end

    def make_a_guess(word_to_guess)
        guessed_letters = []
        non_guessed_letters = []
        attempted_words = []

        possible_letters = ("a".."z").to_a
        print "Welcome to Hangman. Can you guess the word? Make your guess: "
        guess = gets.chomp().downcase
        if guess.length == 0
            until guess.length >= 1
                print "Please, enter a valid guess. No guess is not a guess: "
                guess = gets.chomp().downcase
            end
        elsif guess.length == 1
            while guessed_letters.include?(guess) || non_guessed_letters.include?(guess)
                print "You already chose that letter. Select another one, or make a complete guess: "
                guess = gets.chomp().downcase
            end
            until possible_letters.include?(guess)
                print "Invalid letter. Select a valid letter:"
                guess = gets.chomp().downcase
            end
            if word_to_guess.include?(guess) ? guessed_letters << guess : non_guessed_letters << guess
            @guesses_remaining -= 1
        else
            if guess == word_to_guess
                puts "Correct! You guessed the word, #{word_to_guess}"
                return
            else
                while attempted_words.include?(guess)
                    print "You already attempted that word. Select another one, or make a letter guess: "
                    guess = gets.chomp().downcase
                end
                attempted_words << guess
                @guesses_remaining -= 2
            end

            puts "Guesses remaining: #{guesses_remaining}"
            if guessed_letters.length >=1
                puts "Guessed letters: #{guessed_letters}.join(", ")"
            end
            if non_guessed_letters.length >= 1
                puts "Non-Guessed letters: #{non_guessed_letters}.join(", ")"
            end
            if attempted_words.length >= 1
                puts "Attempted words: #{attempted_words}.join(", ")"
            end
        end
    end
end

class Feedback
    def self.give_feedback(guessed_letters, word_to_guess)
        word_to_guess.each do |character|
            if guessed_letters.include?(character)
                print character
            else
                print "-"
            end
        end
    end
end
