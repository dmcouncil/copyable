module Copyable
  class Railtie < Rails::Railtie
    railtie_name :copyable

    rake_tasks do
      load "tasks/copyable.rake"
    end
  end
end