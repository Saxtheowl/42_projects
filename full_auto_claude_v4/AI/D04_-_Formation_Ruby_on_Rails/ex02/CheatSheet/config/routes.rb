Rails.application.routes.draw do
  root "cheatsheet#convention"

  get "convention", to: "cheatsheet#convention", as: :convention
  get "console", to: "cheatsheet#console", as: :console
  get "ruby", to: "cheatsheet#ruby", as: :ruby
  get "ruby-concepts", to: "cheatsheet#ruby_concepts", as: :ruby_concepts
  get "ruby-numbers", to: "cheatsheet#ruby_numbers", as: :ruby_numbers
  get "ruby-strings", to: "cheatsheet#ruby_strings", as: :ruby_strings
  get "ruby-arrays", to: "cheatsheet#ruby_arrays", as: :ruby_arrays
  get "ruby-hashes", to: "cheatsheet#ruby_hashes", as: :ruby_hashes
  get "rails-folder-structure", to: "cheatsheet#rails_folder_structure", as: :rails_folder_structure
  get "rails-commands", to: "cheatsheet#rails_commands", as: :rails_commands
  get "rails-erb", to: "cheatsheet#rails_erb", as: :rails_erb
  get "editor", to: "cheatsheet#editor", as: :editor
  get "help", to: "cheatsheet#help", as: :help
  get "quick-search", to: "cheatsheet#quick_search", as: :quick_search

  get "up" => "rails/health#show", as: :rails_health_check
end
