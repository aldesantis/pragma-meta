# frozen_string_literal: true

require 'dry-transaction'
require 'json'
require 'zeitwerk'

Zeitwerk::Loader.new.tap do |loader|
  loader.tag = File.basename(__FILE__, ".rb")
  loader.inflector = Zeitwerk::GemInflector.new(__FILE__)
  loader.push_dir(File.expand_path('../..', __FILE__))
  loader.setup
end

module Pragma
  module Operation
  end
end
