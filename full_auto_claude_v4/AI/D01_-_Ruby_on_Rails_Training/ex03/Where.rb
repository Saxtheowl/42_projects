#!/usr/bin/env ruby -w

def find_capital(state_name)
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

  abbreviation = states[state_name]
  if abbreviation
    puts capitals_cities[abbreviation]
  else
    puts "Unknown state"
  end
end

find_capital(ARGV[0])
