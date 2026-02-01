class CheatsheetController < ApplicationController
  LOG_FILE = Rails.root.join("entry_log.txt")

  def convention
    @title = "Convention"
  end

  def console
    @title = "Console"
  end

  def ruby
    @title = "Ruby"
  end

  def ruby_concepts
    @title = "Ruby Concepts"
  end

  def ruby_numbers
    @title = "Ruby Numbers"
  end

  def ruby_strings
    @title = "Ruby Strings"
  end

  def ruby_arrays
    @title = "Ruby Arrays"
  end

  def ruby_hashes
    @title = "Ruby Hashes"
  end

  def rails_folder_structure
    @title = "Rails Folder Structure"
  end

  def rails_commands
    @title = "Rails Commands"
  end

  def rails_erb
    @title = "Rails ERB"
  end

  def editor
    @title = "Editor"
  end

  def help
    @title = "Help"
  end

  def quick_search
    @title = "Quick Search"
  end

  def log_book
    @title = "Log Book"
    @entries = read_entries
  end

  def write_entry
    text = params[:entry_text]
    if text.present?
      timestamp = Time.now.strftime("%d/%m/%Y %H:%M:%S")
      entry = "#{timestamp} : #{text}"
      File.open(LOG_FILE, "a") { |f| f.puts(entry) }
    end
    redirect_to log_book_path
  end

  private

  def read_entries
    return [] unless File.exist?(LOG_FILE)
    File.readlines(LOG_FILE).map(&:chomp).reverse
  end
end
