# Pragma::Macro

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/pragma/macro`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pragma-macro'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pragma-macro

## Usage

### Classes

**Used in:** Index, Show, Create, Update, Destroy

The `Classes` macro is responsible of tying together all the Pragma components: put it into an
operation and it will determine the class names of the related policy, model, decorators and 
contract. You can override any of these classes when defining the operation or at runtime if you
wish.

Example usage:

```ruby
module API
  module V1
    module Article
      module Operation
        class Create < Pragma::Operation::Base
          # Let the macro figure out class names.
          step Pragma::Macro::Classes()
          step :execute!
          
          # But override the contract.
          self['contract.default.class'] = Contract::CustomCreate
          
          def execute!(options)
            # `options` contains the following:
            #    
            #    `model.class`
            #    `policy.default.class`
            #    `policy.default.scope.class`
            #    `decorator.instance.class`
            #    `decorator.collection.class`
            #    `contract.default.class` 
            #    
            # These will be `nil` if the expected classes do not exist.
          end
        end
      end
    end
  end
end
```

### Model

**Used in:** Index, Show, Create, Update, Destroy

The `Model` macro provides support for performing different operations with models. It can either
build a new instance of the model, if you are creating a new record, for instance, or it can find
an existing record by ID.

Example of building a new record:

```ruby
module API
  module V1
    module Article
      module Operation
        class Create < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['model.class'] = ::Article
           
          step Pragma::Macro::Model(:build)
          step :save!
          
          def save!(options)
            # Here you'd usually validate and assign parameters before saving.
  
            # ...
  
            options['model'].save!
          end
        end
      end
    end
  end
end
```

As we mentioned, `Model` can also be used to find a record by ID:

```ruby
module API
  module V1
    module Article
      module Operation
        class Show < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['model.class'] = ::Article
           
          step Pragma::Macro::Model(:find_by), fail_fast: true
          step :respond!
          
          def respond!(options)
            options['result.response'] = Response::Ok.new(
              entity: options['model']
            )
          end
        end
      end
    end
  end
end
```

In the example above, if the record is not found, the macro will respond with `404 Not Found` and a
descriptive error message for you. If you want to override the error handling logic, you can remove 
the `fail_fast` option and instead implement your own `failure` step.

### Policy

**Used in:** Index, Show, Create, Update, Destroy

The `Policy` macro ensures that the current user can perform an operation on a given record.

Here's a usage example:

```ruby
module API
  module V1
    module Article
      module Operation
        class Show < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['policy.default.class'] = Policy
          
          step :model!
          step Pragma::Macro::Policy(), fail_fast: true
          # You can also specify a custom method to call on the policy:
          # step Pragma::Macro::Policy(action: :custom_method), fail_fast: true
          step :respond!
          
          def model!(params:, **)
            options['model'] = ::Article.find(params[:id])
          end
        end
      end
    end
  end
end
```

If the user is not authorized to perform the operation (i.e. if the policy's `#show?` method returns
`false`), the macro will respond with `403 Forbidden` and a descriptive error message. If you want 
to override the error handling logic, you can remove the `fail_fast` option and instead implement 
your own `failure` step.

The macro accepts the following options, which can be defined on the operation or at runtime:

- `policy.context`: the context to use for the policy (optional, `current_user` is used if not
  provided).

### Filtering

**Used in:** Index

The `Filtering` macro provides a simple interface to define basic filters for your API. You simply
include the macro and configure which filters you want to expose to the users.

```ruby
module API
  module V1
    module Article
      module Operation
        class Index < Pragma::Operation::Base
          step :model!
          step Pragma::Macro::Filtering()
          step :respond!

          self['filtering.filters'] = [
            Pragma::Filter::Equals.new(param: :by_category, column: :category_id),
            Pragma::Filter::Ilike.new(param: :by_title, column: :title)
          ]
          
          def model!(params:, **)
            options['model'] = ::Article.all
          end
        end
      end
    end
  end
end
```

With the example above, you are exposing the `by_category` filter and the `by_title` filters. 

The following filters are available for ActiveRecord currently:

- `Equals`: performs an equality (`=`) comparison (requires `:column`)-
- `Like`: performs a `LIKE` comparison (requires `:column`).
- `Ilike`: performs an `ILIKE` comparison (requires `:column`).
- `Where`: adds a generic `WHERE` clause (requires `:condition` and passes the parameter's value as 
   `:value`).
- `Scope`: calls a method on the collection (requires `:scope` and passes the parameter's value as 
   the first argument);
- `Boolean`: calls a method on the collection (requires `:scope` and doesn't pass any arguments).

Support for more clauses as well as more ORMs will come soon.

### Ordering

**Used in:** Index

As the name suggests, the `Ordering` macro allows you to easily implement default and user-defined
ordering.

Here's an example:

```ruby
module API
  module V1
    module Article
      module Operation
        class Index < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['model.class'] = ::Article

          self['ordering.default_column'] = :published_at
          self['ordering.default_direction'] = :desc
          self['ordering.columns'] = %i[title published_at updated_at]

          step :model!

          # This will override `model` with the ordered relation.
          step Pragma::Macro::Ordering(), fail_fast: true

          step :respond!

          def model!(options)
            options['model'] = options['model.class'].all
          end
          
          def respond!(options)
            options['result.response'] = Response::Ok.new(
              entity: options['model']
            )
          end
        end
      end
    end
  end
end
```

If the user provides an invalid order column or direction, the macro will respond with `422 Unprocessable Entity`
and a descriptive error message. If you wish to implement your own error handling logic, you can
remove the `fail_fast` option and implement your own `failure` step.

The macro accepts the following options, which can be defined on the operation or at runtime:

- `ordering.columns`: an array of columns the user can order by.
- `ordering.default_column`: the default column to order by (default: `created_at`).
- `ordering.default_direction`: the default direction to order by (default: `desc`).
- `ordering.column_param`: the name of the parameter which will contain the order column.
- `ordering.direction_param`: the name of the parameter which will contain the order direction.

### Pagination

**Used in:** Index

The `Pagination` macro is responsible for paginating collections of records through 
[will_paginate](https://github.com/mislav/will_paginate). It also allows your users to set the 
number of records per page.

```ruby
module API
  module V1
    module Article
      module Operation
        class Index < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['model.class'] = ::Article

          step :model!

          # This will override `model` with the paginated relation.
          step Pragma::Macro::Pagination(), fail_fast: true

          step :respond!

          def model!(options)
            options['model'] = options['model.class'].all
          end
          
          def respond!(options)
            options['result.response'] = Response::Ok.new(
              entity: options['model']
            )
          end
        end
      end
    end
  end
end
```

In the example above, if the page or per-page number fail validation, the macro will respond with
`422 Unprocessable Entity` and a descriptive error message. If you wish to implement your own error 
handling logic, you can remove the `fail_fast` option and implement your own `failure` step.

The macro accepts the following options, which can be defined on the operation or at runtime:

- `pagination.page_param`: the parameter that will contain the page number.
- `pagination.per_page_param`: the parameter that will contain the number of items to include in each page.
- `pagination.default_per_page`: the default number of items per page.
- `pagination.max_per_page`: the max number of items per page.

This macro is best used in conjunction with the [Collection](https://github.com/pragmarb/pragma-decorator#collection) 
and [Pagination](https://github.com/pragmarb/pragma-decorator#pagination) modules of 
[Pragma::Decorator](https://github.com/pragmarb/pragma-decorator), which will expose all the 
pagination metadata.

### Decorator

**Used in:** Index, Show, Create, Update

The `Decorator` macro uses one of your decorators to decorate the model. If you are using 
[expansion](https://github.com/pragmarb/pragma-decorator#associations), it will also make sure that
the expansion parameter is valid.

Example usage:

```ruby
module API
  module V1
    module Article
      module Operation
        class Show < Pragma::Operation::Base
          # This step can be done by Classes if you want.
          self['decorator.instance.class'] = Decorator::Instance
          
          step :model!
          step Pragma::Macro::Decorator(), fail_fast: true
          step :respond!
          
          def model!(params:, **)
            options['model'] = ::Article.find(params[:id])
          end
          
          def respond!(options)
            # Pragma does this for you in the default operations.
            options['result.response'] = Response::Ok.new(
              entity: options['result.decorator.instance']
            )
          end
        end
      end
    end
  end
end
```

The macro accepts the following options, which can be defined on the operation or at runtime:

- `expand.enabled`: whether associations can be expanded.
- `expand.limit`: how many associations can be expanded at once.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pragma-macro. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pragma::Macro project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pragma-macro/blob/master/CODE_OF_CONDUCT.md).
