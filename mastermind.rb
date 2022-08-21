class Game
  #move to choose role later
  @@code = Array.new(4)
  @@guess_attempted = 0
  @@new_guess = nil
  

  def check_guess
    p @@code
    p @@new_guess
    #code matches answer do this
    if @@new_guess == @@code
      puts "Codebreaker Wins!"
      return
    end
    feedback(@@code, @@new_guess)
    @@guess_attempted += 1
    puts "Guess:#{@@position_value_right} Right and #{@@value_right} only guessed values included in code"
    if @@guess_attempted < 12
      puts "Guess ##{@@guess_attempted}, #{12-@@guess_attempted} remaining"
      guess()
    else
      puts "Codebreaker Loses"
    end
  end
  
  def feedback(code, guess)
    @@position_value_right = 0
    @@value_right = 0
    @@correct = {1 => false, 2 => false, 3 => false, 4 => false, 5 => false, 6 => false}
    code.each_with_index do |slot, index|
      if guess[index] == slot
        @@correct[slot] = true
        @@position_value_right += 1
      end
    end
    code.each_with_index do |slot, index|
      if guess.any?{|guess_digit| guess_digit == slot && @@correct[slot] == false}
        @@value_right += 1
        @@correct[slot] = true
      end
    end
  end

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

  def player_guess
    pc = Computer.new
    pc.generate_code
    player1 = Player.new
    player1.guess
  end

  def computer_guess
    player = Player.new
    player.generate_code
    pc = Computer.new
    pc.guess
  end

end

class Computer < Game
  def setee
    @@code = [3,1,5,3]
  end

  def generate_code
    @@code = @@code.map{|slot| slot = rand(6) + 1}
  end
  
  def guess
    @@old_pc_guess = nil
    if @@guess_attempted == 0
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
      @@not_guessed = @@possible_code.reduce(Hash.new) do |hash, code| 
        hash[code] = 0
        hash
      end
      @@new_guess = 1122.digits.reverse  
      if @@new_guess != @@code
        @@not_guessed.delete(@@new_guess.join.to_i)

      end
      check_guess()
    else
      if @@new_guess != @@code
        @@not_guessed.delete(@@new_guess.join.to_i)
      end
      old_position_value_right = @@position_value_right
      old_value_right = @@value_right 
      #check every possible code in set against the guess to rule out answers that don't give the same feedback
      deleted = 0
      @@possible_code.delete_if do |set|
        feedback(@@new_guess, set.digits.reverse)
        if old_position_value_right != @@position_value_right || old_value_right != @@value_right
          deleted += 1
          true
        end
      end
      p deleted
      calculate_next_guess()
      check_guess()
    end    
  end

  def calculate_next_guess
    max_eliminated = 0
    #for each code not yet guess calculates the minimum codes that came be eliminated from possible codes remaining
    @@not_guessed.each do |code, min_codes_eliminated|
      min = nil
      #check each possible flag return for how many possiblilities it can eliminate from your remaining possible codes
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
      @@not_guessed[code] = min
      if @@possible_code.length == 1
        @@new_guess = @@possible_code[0].digits.reverse
      elsif @@not_guessed[code] > max_eliminated
        max_eliminated = @@not_guessed[code]
        @@new_guess = code.digits.reverse
      #same as max and the code is in the list of possible codes and 
      elsif @@not_guessed[code] == max_eliminated && @@possible_code.include?(code) && code < @@new_guess.join.to_i
        @@new_guess = code.digits.reverse
      end
    end
  end

end

class Player < Game
  def guess
    puts "Enter your guess for the code in format (eg. 1234, each digit can be 1-6)"
    @@new_guess = gets.chomp.to_i.digits.reverse
    if @@new_guess.any?{|slot| slot < 1 || slot > 6} || @@new_guess.length < 4 || @@new_guess.length > 4
      puts "Invalid input."
      guess()
    end
    check_guess()
  end

  def generate_code
    puts "Enter your code in format (eg. 1234, each digit can be 1-6)"
    @@code = gets.chomp.to_i.digits.reverse
    if @@code.any?{|slot| slot < 1 || slot > 6} || @@code.length < 4 || @@code.length > 4
      puts "Invalid input."
      generate_code()
    end
  end


end

pc = Computer.new
pc.choose_role