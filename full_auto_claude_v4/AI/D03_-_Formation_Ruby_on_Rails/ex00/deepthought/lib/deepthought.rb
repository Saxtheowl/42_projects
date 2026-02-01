#!/usr/bin/env ruby -w
# frozen_string_literal: true

require_relative "deepthought/version"
require "colorize"

class Deepthought
  VERSION = DeepthoughtGem::VERSION

  def initialize
  end

  def respond(question)
    if question == "The Ultimate Question of Life, the Universe and Everything"
      puts "42".green
      "42"
    else
      puts "Mmmm i'm bored".red
      "Mmmm i'm bored"
    end
  end
end
