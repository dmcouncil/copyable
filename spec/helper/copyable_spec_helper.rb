require 'spec_helper'

# copyable needs its own set of tables and ActiveRecord models to test with.
require_relative 'test_tables'
Copyable::TestTables.create!
require_relative 'test_models'

# useful for starting off specs with a clean slate
def undefine_copyable_in(klass)
  klass.instance_eval do
    define_method(:create_copy!) do |*args|
      raise "the create_copy! method has been wiped clean for testing purposes"
    end
  end
end
