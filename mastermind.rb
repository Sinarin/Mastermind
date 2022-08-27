class Game
  #intialize main variables

  def start_game
    @@code = Array.new(4)
    @@guess_attempted = 0
    @@new_guess = nil
    game = Game.new
    game.choose_role
  end
  
  private
  def check_guess
    #if code matches guess inform user
    if @@new_guess == @@code
      puts "Codebreaker Wins!"
      play_again
      return
    end
    #if the code does not match give feedback about the guess
    feedback(@@code, @@new_guess)
    @@guess_attempted += 1
    puts "Codebreak's Guess: #{@@new_guess}"
    puts "Guess:#{@@position_value_right} Right and #{@@value_right} only guessed values included in code"
    if @@guess_attempted < 12
      puts "Guess attempted ##{@@guess_attempted}, #{12-@@guess_attempted} remaining \n\n"
      guess()
    else
      puts "Codebreaker Loses"
      play_again
    end
  end

  private
  def play_again
    puts "would you like to play again (y/n)?"
    answer = gets.chomp.downcase
    if answer == "yes" || answer == "y"
      start_game
    else
      puts "Thank you for playing!"
    end
  end

  
  private
  def feedback(code, guess)
    @@position_value_right = 0
    @@value_right = 0
    right_position = {0 => false, 1 => false, 2 => false, 3 => false}
    #record if there is a guessed number that matches a number in the code
    @@correct = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}
    #record if ther is a guessed number that matches number and position
    code.each_with_index do |slot, index|
      if guess[index] == slot
        @@correct[slot] += 1
        @@position_value_right += 1
        right_position[index] = true
      end
    end
    #check if a digit in guess (that hasn't found a pefect match) corresponds to any number in the answer
    guess.each_with_index do |guess_digit, index|
      if right_position[index] == false && @@correct[guess_digit] < code.count(guess_digit)
        if code.include?(guess_digit)
          @@value_right += 1
          @@correct[guess_digit] += 1
        end
      end
    end
  end

  public
  #starts games
  def choose_role
    puts "Codemaker or codebreaker?"
    @@role = gets.chomp.downcase
    if @@role == "codebreaker"
      player_guess()
    elsif @@role == "codemaker"
      computer_guess()
    else
      puts "Invalid input."
      choose_role
    end
  end

  private
  #player is codebreaker
  def player_guess
    pc = Computer.new
    pc.generate_code
    player1 = Player.new
    player1.guess
  end
  
  #pc is codebreaker
  private
  def computer_guess
    player = Player.new
    player.generate_code
    pc = Computer.new
    pc.guess
  end

end




class Computer < Game

  def generate_code
    @@code = @@code.map{|slot| slot = rand(6) + 1}
  end
  
  def guess
    #initialize Donald Knuth algorithm for computer 
    if @@guess_attempted == 0
      #generate an array of all possible codes
      @@possible_code = []
      for a in 1..6
        for b in 1..6
          for c in 1..6
            for d in 1..6
              @@possible_code.push((a.to_s + b.to_s + c.to_s + d.to_s).to_i)
            end
          end
        end
      end
      #makes a hash to record all codes not guessed, value will be used to record the number of posibilities each can eliminate
      @@not_guessed = @@possible_code.reduce(Hash.new) do |hash, code| 
        hash[code] = 0
        hash
      end
      #first guess is 1122
      @@new_guess = 1122.digits.reverse  
      if @@new_guess != @@code
        @@not_guessed.delete(@@new_guess.join.to_i)

      end
      check_guess()
    else
      #delete code from not guessed variables if not a complete match
      if @@new_guess != @@code
        @@not_guessed.delete(@@new_guess.join.to_i)
      end
      #keep a copy of feedback to compare to
      old_position_value_right = @@position_value_right
      old_value_right = @@value_right 
      #check every possible code in set against the guess to rule out answers that don't give the same feedback
      puts "computer is thinking may take a couple minutes..." if @@guess_attempted < 3
      @@possible_code.delete_if do |set|
        feedback(@@new_guess, set.digits.reverse)
        if old_position_value_right != @@position_value_right || old_value_right != @@value_right
          true
        end
      end
      calculate_next_guess()
      check_guess()
    end    
  end

  def calculate_next_guess
    max_eliminated = 0
    #for each code not yet guess calculates the minimum codes that came be eliminated from possible codes remaining
    @@not_guessed.each do |code, min_codes_eliminated|
      min = nil
      #check each possible feedback return for how many possiblilities it can eliminate from your remaining possible codes
      #search Donald Knuth algorithm for further explaination
      for right in 0..4
        for vright in (0..(4 - right))
          possible_eliminated = 0
          @@possible_code.each do |p_code| 
            feedback(code.digits.reverse, p_code.digits.reverse)
            if right != @@position_value_right || vright != @@value_right
              possible_eliminated += 1
            end
          end
          if min == nil
            min = possible_eliminated
          elsif possible_eliminated < min
            min = possible_eliminated
          end
        end
      end
      #guess the only remaining possible answer
      @@not_guessed[code] = min
      if @@possible_code.length == 1
        @@new_guess = @@possible_code[0].digits.reverse
      #if a code can eliminate more that previous change to that code
      elsif @@not_guessed[code] > max_eliminated
        max_eliminated = @@not_guessed[code]
        @@new_guess = code.digits.reverse
      #change code if they eliminate the same amount and the code is in the list of possible codes
      elsif @@not_guessed[code] == max_eliminated && @@possible_code.include?(code) && code < @@new_guess.join.to_i
        @@new_guess = code.digits.reverse
      end
    end
  end

end




class Player < Game
  #checks player guess for valid in put
  def guess
    puts "Enter your guess for the code in format (eg. 1234, each digit can be 1-6)"
    @@new_guess = gets.chomp.to_i.digits.reverse
    if @@new_guess.any?{|slot| slot < 1 || slot > 6} || @@new_guess.length < 4 || @@new_guess.length > 4
      puts "Invalid input."
      guess()
    end
    check_guess()
  end

  #player makes a code for the computer to guess
  def generate_code
    puts "Enter your code in format (eg. 1234, each digit can be 1-6)"
    @@code = gets.chomp.to_i.digits.reverse
    if @@code.any?{|slot| slot < 1 || slot > 6} || @@code.length < 4 || @@code.length > 4
      puts "Invalid input."
      generate_code()
    end
  end


end

puts "You will choose to be the codemaker or codebreaker, the computer will take the other role. \n
The codebreak will get feedback after each guess. The code is a 4 digit code with each digit ranging from 1-6. \n
The feedback will give you how many are completely right and how many values are right but in the wrong place. \n\n"
print "If there are duplicate colors in the guess, they cannot all be awarded a key peg unless they correspond 
to the same number of duplicate colors in the hidden code. For example, if the hidden code is red-red-blue-blue
and the player guesses red-red-red-blue, the codemaker will award two colored key pegs for the two correct reds, 
nothing for the third red as there is not a third red in the code, and a colored key peg for the blue. 
No indication is given of the fact that the code also includes a second blue \n\n"

game = Game.new
game.start_game