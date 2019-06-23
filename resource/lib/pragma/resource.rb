# frozen_string_literal: true

require "pragma/resource/version"

require 'pragma/resource/index'
require 'pragma/resource/show'
require 'pragma/resource/create'
require 'pragma/resource/update'
require 'pragma/resource/destroy'

module Pragma
  module Resource
    class Error < StandardError; end
    # Your code goes here...
  end
end
