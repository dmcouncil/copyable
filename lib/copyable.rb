require "copyable/version"
require 'active_record'

require_relative 'copyable/railtie' if defined?(Rails)

require_relative 'copyable/config'
require_relative 'copyable/copy_registry'
require_relative 'copyable/exceptions'
require_relative 'copyable/model_hooks'
require_relative 'copyable/option_checker'
require_relative 'copyable/saver'
require_relative 'copyable/single_copy_enforcer'

require_relative 'copyable/declarations/declaration'
require_relative 'copyable/declarations/after_copy'
require_relative 'copyable/declarations/associations'
require_relative 'copyable/declarations/columns'
require_relative 'copyable/declarations/disable_all_callbacks_and_observers_except_validate'
require_relative 'copyable/declarations/main'
require_relative 'copyable/declarations/declarations'

require_relative 'copyable/syntax_checking/declaration_stubber'
require_relative 'copyable/syntax_checking/completeness_checker'
require_relative 'copyable/syntax_checking/association_checker'
require_relative 'copyable/syntax_checking/column_checker'
require_relative 'copyable/syntax_checking/declaration_checker'
require_relative 'copyable/syntax_checking/syntax_checker'

require_relative 'copyable/copyable_extension'

# make the copyable declaration available to all ActiveRecord classes
ActiveRecord::Base.send :include, Copyable::CopyableExtension
