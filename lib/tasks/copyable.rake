# This is just a quick-and-dirty convenience task that will output a
# default copyable declaration based on the columns and associations
# of a given model.  It saves you some typing when adding a new
# copyable declaration to a model.
#
#   $ rake copyable model=ModelClassName
#
desc "generate a copyable declaration for a model"
task :copyable => :environment do

  if ENV['model'].blank?
    puts "Usage:  rake copyable model=ModelClassName"
    exit
  end

  begin
    model_class = ENV['model'].constantize
  rescue NameError
    puts "Error: unknown model '#{ENV['model']}'"
    puts "aborting"
    exit
  end

  puts
  puts "copyable do"
  puts "  disable_all_callbacks_and_observers_except_validate"
  puts "  columns({"

  columns = model_class.column_names - ['id', 'created_at', 'updated_at', 'created_on', 'updated_on']
  max_length = columns.map(&:length).max
  columns.sort.each do |column|
    column += ":"
    column = column.ljust(max_length+1)
    puts "    #{column}  :copy,"
  end

  puts "  })"
  puts "  associations({"

  all_associations = model_class.reflect_on_all_associations
  required_associations = all_associations.select do |ass|
    !ass.is_a?(ActiveRecord::Reflection::BelongsToReflection) &&
    !ass.is_a?(ActiveRecord::Reflection::ThroughReflection)    
  end
  associations = required_associations.map(&:name).map(&:to_s)
  max_length = associations.map(&:length).max
  associations.sort.each do |ass|
    ass += ":"
    ass = ass.ljust(max_length+1)
    puts "    #{ass}  :copy,"
  end

  puts "  })"
  puts "end"
  puts
end
