require 'pry'

class Player
  attr_accessor :move, :name

  def initialize
    set_name
  end
end

class Human < Player
  attr_accessor :score, :record

  def initialize
    super
    @score = 0
    @record = []
  end

  def set_name
    n = ""
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock, lizard:"
      choice = gets.chomp
      break if ['rock', 'paper', 'scissors', 'spock', 'lizard'].include?(choice)
      puts "Sorry, invalid choice."
    end
    record << choice
    self.move = Move.new(choice)
  end
end

class Computer < Player
  attr_accessor :score, :record

  PERSONALITIES = {
    'rockloving' => 'R2D2',
    'scissorsloving' => 'Hal',
    'spockloving' => 'Chappie',
    'paperloving' => 'Sonny',
    'lizardloving' => 'Number 5'
  }

  LIKELY_MOVES = {
    'rockloving' => ['rock'],
    'scissorsloving' => ['scissors', 'scissors', 'scissors', 'rock'],
    'spockloving' => ['spock', 'spock', 'spock', 'lizard'],
    'paperloving' => ['paper', 'paper', 'paper', 'spock'],
    'lizardloving' => ['lizard', 'lizard', 'lizard', 'scissors']
  }

  def initialize
    super
    @score = 0
    @record = []
  end

  def set_name
    self.name = Computer::PERSONALITIES.values.sample
  end

  def choose
    personality = Computer::PERSONALITIES.key(name)
    choice = Computer::LIKELY_MOVES[personality].sample
    record << choice
    self.move = Move.new(choice)
  end
end

class Move
  attr_reader :value

  def initialize(value)
    case value
    when 'rock' then @value = Rock.new
    when 'paper' then @value = Paper.new
    when 'scissors' then @value = Scissors.new
    when 'spock' then @value = Spock.new
    when 'lizard' then @value = Lizard.new
    end
  end

  def to_s
    value.class.to_s
  end
end

class Rock
  def beats?(other_move)
    other_move.value.class == Scissors || other_move.value.class == Lizard
  end
end

class Scissors
  def beats?(other_move)
    other_move.value.class == Paper || other_move.value.class == Lizard
  end
end

class Paper
  def beats?(other_move)
    other_move.value.class == Rock || other_move.value.class == Spock
  end
end

class Spock
  def beats?(other_move)
    other_move.value.class == Scissors || other_move.value.class == Rock
  end
end

class Lizard
  def beats?(other_move)
    other_move.value.class == Paper || other_move.value.class == Spock
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    system("clear")
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Hello, #{human.name}!"
    puts "Welcome to Rock, Paper, Scissors, Spock, and Lizard!"
    puts "Your opponent is #{computer.name}."
    puts "The first one to reach a score of 10 is the grand winner."
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock and Lizard. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if who_is_winner.nil?
      puts "It's a tie!"
    else
      puts "The winner is #{who_is_winner}!"
    end
  end

  def who_is_winner
    if human.move.value.beats?(computer.move)
      human.name
    elsif computer.move.value.beats?(human.move)
      computer.name
    end
  end

  def update_score
    case who_is_winner
    when human.name then human.score += 1
    when computer.name then computer.score += 1
    end
  end

  def winner?
    human.score == 10 || computer.score == 10
  end

  def display_score
    msg = "#{human.name} #{human.score} : #{computer.score} #{computer.name}"
    divider = ('*' * (msg.size + 2)).to_s
    puts divider
    puts msg.center(divider.size)
    puts divider
  end

  def display_move_history
    rounds = human.record.size
    msg = "#{human.name} played #{rounds} rounds against #{computer.name}:"
    length = msg.size + 2
    divider = ('*' * length).to_s
    puts divider
    puts msg
    display_past_moves
    puts divider
  end

  def display_past_moves
    rounds = human.record.size
    0.upto(rounds - 1) do |index|
      puts "#{human.record[index]} vs. #{computer.record[index]}"
    end
  end

  def display_final_winner
    final_winner = human.name if human.score == 10
    final_winner = computer.name if computer.score == 10
    puts "The grand victory goes to...#{final_winner}!!"
  end

  def continue?
    answer = nil
    loop do
      puts "Do you want to continue to the next round? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end
    answer == 'y'
  end

  def play_again?
    initialize_score
    initialize_move_history
    answer = nil
    loop do
      puts "Do you want to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end
    answer == 'y'
  end

  def initialize_score
    human.score = 0
    computer.score = 0
  end

  def initialize_move_history
    human.record = []
    computer.record = []
  end

  def round
    human.choose
    computer.choose
    display_moves
    display_winner
    update_score
    display_score
  end

  def end_of_game_display
    display_move_history if winner?
    display_final_winner if winner?
  end

  def main_game
    loop do
      loop do
        round
        break if winner?
        break unless continue?
        system("clear")
      end
      end_of_game_display
      break unless play_again?
    end
  end

  def play
    system("clear")
    display_welcome_message
    main_game
    display_goodbye_message
  end
end

RPSGame.new.play
