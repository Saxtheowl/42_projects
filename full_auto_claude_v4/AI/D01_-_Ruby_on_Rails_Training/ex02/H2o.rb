#!/usr/bin/env ruby -w

def convert_to_hash_and_display
  data = [['Caleb'   , 24],
          ['Calixte' , 84],
          ['Calliste', 65],
          ['Calvin'  , 12],
          ['Cameron' , 54],
          ['Camil'   , 32],
          ['Camille' , 5],
          ['Can'     , 52],
          ['Caner'   , 56],
          ['Cantin'  , 4],
          ['Carl'    , 1],
          ['Carlito' , 23],
          ['Carlo'   , 19],
          ['Carlos'  , 26],
          ['Carter'  , 54],
          ['Casey'   , 2]]

  hash = {}
  data.each do |name, number|
    hash[number] = name
  end

  hash.each do |number, name|
    puts "#{number} : #{name}"
  end
end

convert_to_hash_and_display
