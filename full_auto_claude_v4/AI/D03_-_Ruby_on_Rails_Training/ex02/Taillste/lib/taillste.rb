#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true

require_relative "taillste/version"

module Taillste
  class List
    attr_reader :items

    def initialize(items = [])
      @items = items.dup
    end

    def length
      @items.length
    end

    def empty?
      @items.empty?
    end

    def first
      @items.first
    end

    def last
      @items.last
    end

    def head
      first
    end

    def tail
      return nil if @items.empty?
      List.new(@items[1..-1] || [])
    end

    def push(item)
      @items.push(item)
      self
    end

    def pop
      @items.pop
    end

    def shift
      @items.shift
    end

    def unshift(item)
      @items.unshift(item)
      self
    end

    def reverse
      List.new(@items.reverse)
    end

    def reverse!
      @items.reverse!
      self
    end

    def map(&block)
      List.new(@items.map(&block))
    end

    def select(&block)
      List.new(@items.select(&block))
    end

    def reject(&block)
      List.new(@items.reject(&block))
    end

    def reduce(initial = nil, &block)
      if initial
        @items.reduce(initial, &block)
      else
        @items.reduce(&block)
      end
    end

    def include?(item)
      @items.include?(item)
    end

    def to_a
      @items.dup
    end

    def to_s
      @items.to_s
    end

    def ==(other)
      return false unless other.is_a?(List)
      @items == other.items
    end

    def [](index)
      @items[index]
    end

    def []=(index, value)
      @items[index] = value
    end

    def each(&block)
      @items.each(&block)
      self
    end

    def sort(&block)
      if block_given?
        List.new(@items.sort(&block))
      else
        List.new(@items.sort)
      end
    end

    def sort!(&block)
      if block_given?
        @items.sort!(&block)
      else
        @items.sort!
      end
      self
    end

    def uniq
      List.new(@items.uniq)
    end

    def flatten
      List.new(@items.flatten)
    end

    def compact
      List.new(@items.compact)
    end

    def take(n)
      List.new(@items.take(n))
    end

    def drop(n)
      List.new(@items.drop(n))
    end

    def zip(*others)
      other_arrays = others.map { |o| o.is_a?(List) ? o.to_a : o }
      List.new(@items.zip(*other_arrays))
    end

    def concat(other)
      other_array = other.is_a?(List) ? other.to_a : other
      List.new(@items + other_array)
    end

    def +(other)
      concat(other)
    end
  end
end
