#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require "colorize"
require_relative "deepthought/version"

class Deepthought
  def initialize
  end

  def respond(question)
    if question == "The Ultimate Question of Life, the Universe and Everything"
      puts "42".green
      return "42"
    else
      puts "Mmmm i'm bored".red
      return "Mmmm i'm bored"
    end
  end
end
