#!/usr/bin/env ruby -w

def read_and_sort_numbers
  file_path = File.join(File.dirname(__FILE__), 'numbers.txt')
  content = File.read(file_path)
  numbers = content.split(',').map(&:to_i)
  numbers.sort.each { |n| puts n }
end

read_and_sort_numbers
