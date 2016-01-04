# Allow users of copyable to alter the behavior.

module Copyable

  class Config < Struct.new(:suppress_schema_errors); end

  def self.config
    @@config ||= Config.new
  end

end

if ENV['SUPPRESS_SCHEMA_ERRORS'].nil?
  Copyable.config.suppress_schema_errors = false
else
  Copyable.config.suppress_schema_errors =
   (ENV['SUPPRESS_SCHEMA_ERRORS'] == 'true' ||
    ENV['SUPPRESS_SCHEMA_ERRORS'] == true)
end
