#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to comment/uncomment views
# Usage: ruby views_com.rb [co|unco]
# co: comment views
# unco: uncomment views

require 'fileutils'

def comment_views
  puts 'Commenting views...'
end

def uncomment_views
  puts 'Uncommenting views...'
end

case ARGV[0]
when 'co'
  comment_views
when 'unco'
  uncomment_views
else
  puts 'Usage: ruby views_com.rb [co|unco]'
end
