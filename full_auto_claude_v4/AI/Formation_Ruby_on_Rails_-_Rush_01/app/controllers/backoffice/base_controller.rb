# frozen_string_literal: true

module Backoffice
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_manager!

    layout 'backoffice'
  end
end
