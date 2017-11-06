require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid
  # TODO: generate random grid of letters
  grid = []
  alphabet = ("A".."Z").to_a
  1.upto(10) do
    grid << alphabet.sample(1)[0]
  end
    grid
  end

  def word_in_grid?(user_word, grid)
  test = true
  user_word.upcase!
  user_word.chars.each do |letter|
    test = false if !grid.include?(letter) || (user_word.chars.count(letter) > grid.count(letter))
  end
  test
  end

  def word_in_dictionary?(user_word)
    url = "https://wagon-dictionary.herokuapp.com/#{user_word}"
    api_word_json = open(url).read
    hash_word = JSON.parse(api_word_json)
    hash_word["found"]
  end

  def give_score(word_in_grid, word_in_dictionary, word, time)
    if word_in_dictionary
      if word_in_grid
        return((1000 * word.size) / time).to_f
      else
        return 0
      end
    else
      return 0
    end
  end

  def give_message(word_in_grid, word_in_dictionary, attempt)
  if word_in_dictionary
    if word_in_grid
      return "Congratulations! #{attempt.upcase} is a valid English word!"
    else
      return "Sorry, #{attempt} is not in the grid"
    end
  else
    return "Sorry, #{attempt} is not an english word"
  end
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  word_in_grid = word_in_grid?(attempt, grid)
  word_in_dictionary = word_in_dictionary?(attempt)
  time = (end_time - start_time).to_i
  score = give_score(word_in_grid, word_in_dictionary, attempt, time)
  message = give_message(word_in_grid, word_in_dictionary, attempt)
  {message: message, score: score}
end

  def new
    @letters = generate_grid
    @start_time = Time.now.to_i
  end

  def score
    @word = params[:word]
    @grid = params[:grid].split("")
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    @message = run_game(@word, @grid, @start_time, @end_time)
  end


end
