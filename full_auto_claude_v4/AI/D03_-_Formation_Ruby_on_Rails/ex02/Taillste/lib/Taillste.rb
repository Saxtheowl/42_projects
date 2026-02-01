#!/usr/bin/env ruby -w
# frozen_string_literal: true

require_relative "Taillste/version"

class Taillste
  VERSION = TaillsteGem::VERSION

  attr_reader :size

  def initialize
    @data = []
    @size = 0
  end

  def add(element)
    @data << element
    @size += 1
    self
  end

  def get(index)
    return nil if index < 0 || index >= @size
    @data[index]
  end

  def remove(index)
    return nil if index < 0 || index >= @size
    removed = @data.delete_at(index)
    @size -= 1
    removed
  end

  def first
    @data.first
  end

  def last
    @data.last
  end

  def empty?
    @size == 0
  end

  def clear
    @data = []
    @size = 0
    self
  end

  def to_a
    @data.dup
  end

  def include?(element)
    @data.include?(element)
  end

  def each(&block)
    @data.each(&block)
    self
  end

  def map(&block)
    @data.map(&block)
  end

  def select(&block)
    @data.select(&block)
  end

  def reverse
    @data.reverse
  end
end
