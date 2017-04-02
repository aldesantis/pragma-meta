# frozen_string_literal: true

require 'trailblazer/operation'

require 'pragma/operation/version'
require 'pragma/operation/base'

require 'pragma/operation/response'
require 'pragma/operation/response/not_found'
require 'pragma/operation/response/forbidden'
require 'pragma/operation/response/unprocessable_entity'
require 'pragma/operation/response/created'
require 'pragma/operation/response/ok'

module Pragma
  # Operations provide business logic encapsulation for your JSON API.
  #
  # @author Alessandro Desantis
  module Operation
  end
end
