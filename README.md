# Copyable

[![Code Climate](https://codeclimate.com/github/dmcouncil/copyable/badges/gpa.svg)](https://codeclimate.com/github/dmcouncil/copyable)

Copyable makes it easy to copy ActiveRecord models.

# Installation

Add this line to your application's Gemfile:

    gem 'copyable'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install copyable

# Usage


## Basic Usage

Copyable gives you a `create_copy!` method that you can use to copy ActiveRecord models:

    isaiah = Book.create!(title: "Isaiah")
    copy_of_isaiah = isaiah.create_copy!

Now there are two books called "Isaiah" in the database.



## The Copyable Declaration

In order for an ActiveRecord model class to have the `create_copy!` method defined on it, you need to add a copyable declaration:

    class Book < ActiveRecord::Base

      copyable do
        ...
      end

    end

The copyable declaration has its own DSL for describing how this model should be copied.



## The Columns Declaration

The columns declaration specifies how each individual column should be copied:

    copyable do
      ...
      columns({
        title:      :copy,
        isbn:       :copy,
        author_id:  :copy,
      })
      ...
    end

Every column *must* be listed here (with the exception of `id`, `created_at`, `created_on`, `updated_at` or `updated_on`).

After each column name, give advice on how to copy that column.  The advice must be one of the following:

* `:copy`
* `:do_not_copy`
* `lambda { |orig| ... }`

`:copy` copies the value from the original model. `:do_not_copy` simply places `nil` in the column.  Using a block lets you calculate the value of the column.  The block is passed the original ActiveRecord model object that is being copied.

Here's another example:

    copyable do
      ...
      columns({
        title:      lambda { |orig| "Copy of #{orig.title}" },
        isbn:       :do_not_copy,
        author_id:  :copy,
      })
      ...
    end



## The Associations Declaration

The associations declaration specifies whether to copy the associated models:

    copyable do
      ...
      associations({
        pages:     :copy,
        pictures:  :copy,
        readers:   :do_not_copy,
      })
      ...
    end

Every association *must* be listed here, with two exceptions:

* `belongs_to` associations must not be listed here.  Since `belongs_to` associations will have a foreign key column, the association will be copied when its column is copied.
* `has_many :through` associations must not be listed here, because they are always associated with a related `has_many` association that will already have been listed.

The advice must be one of the following:

* `:copy`
* `:do_not_copy`
* `:copy_only_habtm_join_records`

`:copy` will iterate through each model in the association, creating a copy.  Note that the associated model class must also have a copyable declaration, so that we know how to copy it!

`:do_not_copy` does nothing.

`:copy_only_habtm_join_records` can only be used on `has_and_belongs_to_many` associations.  In fact, you can't use `:copy` on `has_and_belongs_to_many` associations.  Models associated via habtm are never actually copied, but their associations in the relevant join table can be.



## Callbacks

It depends on the situation as to whether you would want a particular callback to be fired when a model is copied.  Since the logic of callbacks is situational, Copyable makes the decision to bypass callbacks
when saving the copied models by using raw SQL insert statements during the copy. It will check
validations unless `skip_validations` is passed to `create_copy`.

## The After Copy Declaration

In case you wanted to make sure a particular callback is run, or in case you had some special custom copying behavior, an `after_copy` declaration is provided that is called after the model has been copied. It is passed the original model and the newly copied model. Note that all callbacks and observers are disabled during the execution of the `after_copy` block, so you must call them explicitly if you want them to run.

    copyable do
      ...
      after_copy do |original_model, new_model|
        new_model.foo = "bar"
        new_model.save!
      end
    end



## Putting It All Together

Here is an example of all four declarations being used in a copyable declaration.  Note that all declarations are required except for `after_copy`.

    copyable do
      disable_all_callbacks_and_observers_except_validate
      columns({
        title:      lambda { |orig| "Copy of #{orig.title}" },
        isbn:       :do_not_copy,
        author_id:  :copy,
      })
      associations({
        pages:     :copy,
        pictures:  :copy,
        readers:   :do_not_copy,
      })
      after_copy do |original_book, new_book|
        puts "There is now a new book: #{new_book.inspect}."
      end
    end



## create_copy!

The `create_copy!` method allows you to override column values by passing in a hash.

    isaiah = Book.create!(title: "Isaiah")
    copy_of_isaiah = isaiah.create_copy!
    copy_of_isaiah2 = isaiah.create_copy!(override: { title: "Foo" })

`copy_of_isaiah.title` will be "Copy of Isaiah" (or whatever the advice was given in the columns declaration).

`copy_of_isaiah2.title` will be "Foo".

Note that you pass in column names only, so if you want to update a `belongs_to` association, you must pass in the column name, not the association name.

    isaiah.create_copy!(override: { author: "Isaiah" })   # NO, bad programmer
    isaiah.create_copy!(override: { author_id: 34 })      # YES

You can skip the running of validations on the copied model and its associated models.  While this is not usually advisable, if you are copying a large data structure (which can take a while), you can increase the performance by skipping validations:

    # turn off validations
    isaiah.create_copy!(skip_validations: true)

    # turn off validations and override columns
    isaiah.create_copy!(override: { title: "Foo" }, skip_validations: true)



## Configuring

You can configure copyable's behavior by setting a configuration parameter after you've loaded copyable.

Currently copyable only has one configuration setting:

    Copyable.config.suppress_schema_errors = false

This is `false` by default. Set this to true if you don't want Copyable to complain with a ColumnError or AssociationError if your database schema does not match your copyable declarations.

You can also set an environment variable called `SUPPRESS_SCHEMA_ERRORS` to true.



## Design Approach

***Future-proof:***  Since Copyable forces you to declare the copying behavior for each and every column and association, when you add columns or associations to a model you are forced to revisit the copying behavior.  This keeps the copying logic up-to-date with the model as it grows and changes.

***Declarative:***  The declarative DSL style, although harder to debug under-the-hood, makes it much easier to work with in the model.  It allows you to forget about all of the intricacies and edge cases of ActiveRecord and instead focus on describing the copying logic of your model.

***Helpful Error Messages:***  Because DSLs can be hard to debug, a concerted effort was made to provide clear error messages for user-friendly debugging.



## Strengths

* handles polymorphic associations
* `create_copy!` is run in a database transaction
* keeps track of which models have already been copied so that it does not re-copy them if it comes across them again (helpful for complex model hierarchies with redundant associations)



## Limitations

* not thread-safe
* copying very large data structures may use a lot of memory
* not designed with performance (CPU or database) in mind
* had to monkey-patch Rails
* postponed support for single table inheritance until needed
* postponed support for keeping `counter_cache` correct until needed



## Convenience

A rake task is included that will output a basic copyable declaration given a model name. Basically, this saves you some typing.

    $ rake copyable model=User



## Gotchas

### Creating Objects in `after_copy`

copyable keeps track of which models have already been copied so as not to reduplicate models if it comes across the same model through different associations. If you are creating new objects in `after_copy!` (such as manually copying an association instead of letting copyable do it), you do not have the benefit of copyable's checking whether the models have already been copied and may end up creating too many copies.

So the recommended approach is to use `after_copy` to tweak the columns of the copied record but to avoid creating new records here.



## Contributing

1. Fork it ( https://github.com/[my-github-username]/copyable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## About

Copyable was developed at [District Management Group](https://dmgroupK12.com).
