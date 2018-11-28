module Copyable
  module CopyableExtension

    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods

      # Use this copyable declaration in an ActiveRecord model to instruct
      # the model how to copy itself.  This declaration will create a
      # create_copy! method that follows the instructions in the copyable
      # declaration.
      def copyable(&block)

        begin
          model_class = self
          # raise an error if the copyable declaration is stated incorrectly
          SyntaxChecker.check!(model_class, block)
          # "execute" the copyable declaration, which basically saves the
          # information listed in the declaration for later use by the
          # create_copy! method
          main = Declarations::Main.new
          main.execute(block)
        rescue => e
          # if suppressing schema errors, don't raise an error, but also don't define a create_copy! method since it would have broken behavior
          return if (e.is_a?(Copyable::ColumnError) || e.is_a?(Copyable::AssociationError) || e.is_a?(ActiveRecord::StatementInvalid)) && Copyable.config.suppress_schema_errors == true
          raise
        end

        # define a create_copy! method for use on model objects
        define_method(:create_copy!) do |options={}|

          # raise an error if passed invalid options
          OptionChecker.check!(options)

          # we basically wrap the method in a lambda to help us manage
          # running it in a transaction
          do_the_copy = lambda do |options|
            new_model = nil
            begin
              # start by disabling all callbacks and observers (except for
              # validation callbacks and observers)
              ModelHooks.disable!(model_class)
              # rename self for clarity
              original_model = self
              # create a brand new, empty model
              new_model = model_class.new
              # fill in each column of this brand new model according to the
              # instructions given in the copyable declaration
              column_overrides = options[:override] || {}
              # merge with global override hash if exists
              column_overrides = column_overrides.merge(options[:global_override]) if options[:global_override]
              Declarations::Columns.execute(main.column_list, original_model, new_model, column_overrides)
              # save that sucker!
              Copyable::Saver.save!(new_model, options[:skip_validations])
              # tell the registry that we've created a new model (the registry
              # helps keep us from creating another copy of a model we've
              # already copied)
              CopyRegistry.register(original_model, new_model)
              # for this brand new model, visit all of the associated models,
              # making new copies according to the instructions in the copyable
              # declaration

              skip_associations = options[:skip_associations] || []
              Declarations::Associations.execute(main.association_list, original_model, new_model, options[:global_override], options[:skip_validations], skip_associations)
              # run the after_copy block if it exists
              Declarations::AfterCopy.execute(main.after_copy_block, original_model, new_model)
            ensure
              # it's critically important to re-enable the callbacks and
              # observers or they will stay disabled for future web
              # requests
              ModelHooks.reenable!(model_class)
            end
            # it's polite to return the newly created model
            new_model
          end


          # create_copy! can end up calling itself (by copying associations).
          # There is some behavior that we want to be slightly different if
          # create_copy! is called from within another create_copy! call.
          # (This means that any create_copy! call in copyable's internal
          # code should pass { __called_recursively: true } to create_copy!.
          if options[:__called_recursively]
            do_the_copy.call(options)
          else
            # Imagine the case where you have a model hierarchy such as
            # a Book that has many Sections that has many Pages.
            #
            # When @book.create_copy! is called, the CopyRegistry will keep
            # track of all of the copied models, making sure no model is
            # re-duplicated (such as in an unusual case where book sections
            # actually overlapped, and therefore two different sections
            # contained some of the same pages--you wouldn't want to re-copy
            # the pages).
            #
            # If we don't clear the registry before we start @book.create_copy!,
            # then we can't do this:
            #
            #    copy1 = @book.create_copy!
            #    copy2 = @book.create_copy!
            #
            # since when copying copy2, the CopyRegistry will remember the
            # Sections and Pages that it copied for copy1 and therefore
            # they won't get recopied.  So we have to clear the CopyRegistry's
            # memory each time before create_copy! is called.
            CopyRegistry.clear
            # Nested transactions can end up swallowing ActiveRecord::Rollback
            # errors in surprising ways.  create_copy! can eventually call
            # create_copy! when copying associated objects, which can result
            # in nested transactions.  We use this option to avoid the nesting.
            ActiveRecord::Base.transaction do
              do_the_copy.call(options)
            end
          end
        end
      end

    end
  end
end
