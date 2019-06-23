# frozen_string_literal: true

require 'pragma/filter/base'
require 'pragma/filter/boolean'
require 'pragma/filter/equals'
require 'pragma/filter/ilike'
require 'pragma/filter/like'
require 'pragma/filter/scope'
require 'pragma/filter/where'

module Pragma
  module Filter
    class Error < StandardError; end
    # Your code goes here...
  end
end

module Pragma
  module Operation
    Filter = Pragma::Filter
  end
end
