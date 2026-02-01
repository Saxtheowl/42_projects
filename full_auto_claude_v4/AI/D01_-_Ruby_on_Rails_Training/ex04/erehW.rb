#!/usr/bin/env ruby -w

def find_state(capital_name)
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

  capitals_to_states = {}
  states.each do |state, abbr|
    capital = capitals_cities[abbr]
    capitals_to_states[capital] = state
  end

  state = capitals_to_states[capital_name]
  if state
    puts state
  else
    puts "Unknown capital city"
  end
end

find_state(ARGV[0])
