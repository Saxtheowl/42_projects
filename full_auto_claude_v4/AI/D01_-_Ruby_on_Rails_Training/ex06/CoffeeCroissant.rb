#!/usr/bin/env ruby -w

def sort_and_display
  data = [
    ['Frank', 33],
    ['Stacy', 15],
    ['Juan' , 24],
    ['Dom'  , 32],
    ['Steve', 24],
    ['Jill' , 24]
  ]

  sorted = data.sort_by { |name, age| [age, name] }
  sorted.each { |name, age| puts name }
end

sort_and_display
