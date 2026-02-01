require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module LifeProTips
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.filter_parameters += [:password, :password_confirmation]
  end
end
