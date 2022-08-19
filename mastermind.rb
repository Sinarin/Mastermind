class Game
  @@code = Array.new(4)
  @@blanks = false
  @@guess_attempt = 0
  @@new_guess = nil



  def check_position_number
    if @@new_guess == @@code
      puts "You Win!"
      break
    end
    @@position_value_right= 0
    @@value_right= 0
    @@correct = {1 => false, 2 => false, 3 => false, 4 => false, 5 => false, 6 => false}
    @@code.each_with_index do |slot, index|
      if @@new_guess[index] == slot[index]
        @@correct[slot] = true
        @@position_value_right += 1
      elsif @@new_guess.any?{|guess| guess == slot && @@correct[slot] == false}
        value_right += 1
        @@correct[slot] = true
      end
      @@guess_attempt += 1
    end
    puts "Guess:#{@@position_value_right} Right + #{@@value_right} only values included in code"
    if @@guess_attempt < 12
      puts "Guess ##{@@guess_attempt} #{12-@@guess_attempt} remaining"
      guess()
    else
      puts "You Lose"
  end


end

class Computer < Game
  def generate_code
    @@code.map{|slot| slot = rand(6) + 1}
  end
end

class Player < Game
  def guess
    puts "Enter your guess for the code in format (eg. 1234, each digit can be 1-6)"
    @@new_guess = get.chomp.to_i.digits
    if @@new_guess.any?{|slot| slot < 1 || slot > 6}
      puts "Invalid input."
      guess()
    end
    check_guess(new_guess)
  end
end

pc = Computer.new
pc.generate_code
player1 = Player.new
player1.guess

=begin
  
computer generates code

plaayer guesses

check guesses

guess ++

if right +> win


  if wrong =>
    if guess < 12 
    feed back
    print remainder guesses
    else end game


