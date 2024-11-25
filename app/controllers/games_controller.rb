require 'net/http'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
  end

  def score
    @word = params[:word].upcase
    @letters = params[:letters].split

    if valid_word?(@word, @letters)
      api_response = check_word_api(@word)
      @result = word_valid?(api_response)
      update_score(api_response['length'])
    else
      @result = word_invalid(@word, @letters)
    end
  end

  private

  def valid_word?(word, letters)
    word.chars.all? { |char| word.count(char) <= letters.count(char) }
  end

  def check_word_api(word)
    uri = URI("https://dictionary.lewagon.com/#{word}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def word_valid?(api_response)
    if api_response['found']
      "Congratulations! #{@word} is a valid English word! Score: #{api_response['length']}"
    else
      "Sorry but #{@word} doesn't seem to be a valid English word..."
    end
  end

  def word_invalid(word, letters)
    "Sorry but #{word} can't be built out of #{letters.join(', ')}"
  end

  def update_score(word_length)
    session[:score] ||= 0
    session[:score] += word_length.to_i
  end
end
