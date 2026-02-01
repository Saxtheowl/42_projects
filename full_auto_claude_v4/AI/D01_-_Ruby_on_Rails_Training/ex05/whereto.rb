#!/usr/bin/env ruby -w

def whereto(input)
  states = {
    "Oregon"     => "OR",
    "Alabama"    => "AL",
    "New Jersey" => "NJ",
    "Colorado"   => "CO"
  }

  capitals_cities = {
    "OR" => "Salem",
    "AL" => "Montgomery",
    "NJ" => "Trenton",
    "CO" => "Denver"
  }

  return if ARGV.length != 1
  return if input.include?(",,")

  states_downcase = {}
  states.each { |k, v| states_downcase[k.downcase] = [k, v] }

  capitals_downcase = {}
  capitals_cities.each do |abbr, capital|
    state = states.key(abbr)
    capitals_downcase[capital.downcase] = [capital, state, abbr]
  end

  words = input.split(',')
  words.each do |word|
    word_clean = word.strip.downcase
    next if word_clean.empty?

    if states_downcase[word_clean]
      state_name, abbr = states_downcase[word_clean]
      capital = capitals_cities[abbr]
      puts "#{capital} is the capital of #{state_name} (akr: #{abbr})"
    elsif capitals_downcase[word_clean]
      capital, state, abbr = capitals_downcase[word_clean]
      puts "#{capital} is the capital of #{state} (akr: #{abbr})"
    else
      original_word = word.strip
      puts "#{original_word} is neither a capital city nor a state"
    end
  end
end

whereto(ARGV[0])
