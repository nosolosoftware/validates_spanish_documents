# ValidatesSpanishDocuments

Common validations of spanish identification documents.

## Installation

Add this line to your application's Gemfile:

    gem 'validates_spanish_documents'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validates_spanish_documents

## Methods

* **validate_dni(field_name, options)**: check if it is valid dni
* **validate_nie(field_name, options)**: check if it is valid nie
* **validate_cif(field_name, options)**: check if it is valid cif
* **validate_nif(field_name, options)**: check if it is valid dni, nie or cif
* **validate_person_nif(field_name, options)**: check if it is valid dni or nie

## Options

* **if**: name of boolean field or method to conditional validation

## Example

```ruby
class Entity
  include Mongoid::Document
  include NssValidations

  field :dni
  field :nie
  field :cif
  field :nif
  field :person_nif

  validate_dni :dni
  validate_nie :nie
  validate_cif :cif
  validate_nif :nif, if: :condition
  validate_person_nif :person_nif

  def condition
    return true
  end
end
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/validates_spanish_documents/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
