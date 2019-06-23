# frozen_string_literal: true

require 'adaptor'

require 'pragma/operation'
require 'pragma/policy'
require 'pragma/contract'
require 'pragma/decorator'

require 'pragma/version'

require 'pragma/operation/filter'

require 'pragma/operation/macro'

require 'pragma/association_includer/base'
require 'pragma/association_includer/active_record'
require 'pragma/association_includer/poro'
require 'pragma/association_includer'

require 'pragma/operation/index'
require 'pragma/operation/show'
require 'pragma/operation/create'
require 'pragma/operation/update'
require 'pragma/operation/destroy'

# A pragmatic architecture for building JSON APIs.
#
# @author Alessandro Desantis
module Pragma
end
