# frozen_string_literal: true

Zeitwerk::Loader.new.tap do |loader|
  loader.tag = File.basename(__FILE__, ".rb")
  loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
  loader.push_dir(File.expand_path('..', __dir__))
  loader.setup
end

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
