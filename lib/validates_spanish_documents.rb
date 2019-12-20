require 'validates_spanish_documents/version'

##
# Add common valiations methods
#
module ValidatesSpanishDocuments
  LETTERS_DNI = %w[T R W A G M Y F P D X B N J Z S Q V H L C K E].freeze
  REGEX_DNI = /^(\d{8})\-?(#{LETTERS_DNI.join('|')})$/

  LETTERS_NIE = %w[X Y Z].freeze
  REGEX_NIE = /^(#{LETTERS_NIE.join('|')})\-?(\d{7})(#{LETTERS_DNI.join('|')})$/

  LETTERS_CIF = %w[A B C D E F G H J N P Q R S U V W].freeze
  LETTERS_CIF_NUMBER = %w[P Q S W].freeze
  LETTERS_CIF_CONTROL = %w[J A B C D E F G H I].freeze
  REGEX_CIF = /^(#{LETTERS_CIF.join('|')})\-?(\d{7})\-?(\d|#{LETTERS_CIF_CONTROL.join('|')})$/

  # rubocop:disable Metrics/ModuleLength
  module InstanceMethods
    private

    # Check validate nif
    def nif_valid?(field_name)
      if send(field_name).match?(REGEX_DNI)
        dni_valid?(field_name)
      elsif send(field_name).match?(REGEX_NIE)
        nie_valid?(field_name)
      else
        cif_valid?(field_name)
      end
    end

    # Check validate PERSON NIF
    def person_nif_valid?(field_name)
      if send(field_name).match?(REGEX_DNI)
        dni_valid?(field_name)
      else
        nie_valid?(field_name)
      end
    end

    # Check validate DNI
    def dni_valid?(field_name)
      if send(field_name) =~ REGEX_DNI
        number = Regexp.last_match(1).to_i
        position = number % 23
        control_code = Regexp.last_match(2)

        return true if control_code == LETTERS_DNI[position]
      end

      false
    end

    # Check validate NIE
    def nie_valid?(field_name)
      if send(field_name) =~ REGEX_NIE
        number_first = LETTERS_NIE.index(Regexp.last_match(1))
        number = (number_first.to_s + Regexp.last_match(2)).to_i
        position = number % 23
        control_code = Regexp.last_match(3)

        return true if control_code == LETTERS_DNI[position]
      end

      false
    end

    # Check validate CIF
    def cif_valid?(field_name)
      if send(field_name) =~ REGEX_CIF
        number = Regexp.last_match(2)
        first_letter = Regexp.last_match(1)
        province_code = number[0..1]
        actual_control = Regexp.last_match(3)

        total = number
                .split('')
                .each_with_index
                .inject(0) do |acc, (element, index)|
          acc + if index.even?
                  (element.to_i * 2).digits.inject(:+)
                else
                  element.to_i
                end
        end

        decimal = total.digits.first
        expected_control = decimal != 0 ? 10 - decimal : decimal

        # Control code must be a letter
        return LETTERS_CIF_CONTROL[expected_control] if LETTERS_CIF_NUMBER.include?(first_letter) ||
                                                        province_code == '00'

        # Control code will be a number or a letter
        return [expected_control.to_s,
                LETTERS_CIF_CONTROL[expected_control]].include?(actual_control)
      end

      false
    end

    # Validate NIF method
    def validate_nss_nif(field_name)
      unless nif_valid?(field_name)
        errors.add field_name, :invalid
        false
      end

      true
    end

    # Validate NIF method
    def validate_nss_person_nif(field_name)
      unless person_nif_valid?(field_name)
        errors.add field_name, :invalid
        false
      end

      true
    end

    # Validate DNI method
    def validate_nss_dni(field_name)
      unless dni_valid?(field_name)
        errors.add field_name, :invalid
        false
      end

      true
    end

    # Validate NIE method
    def validate_nss_nie(field_name)
      unless nie_valid?(field_name)
        errors.add field_name, :invalid
        false
      end

      true
    end

    # Validate CIF method
    # https://es.wikipedia.org/wiki/C%C3%B3digo_de_identificaci%C3%B3n_fiscal
    def validate_nss_cif(field_name)
      unless cif_valid?(field_name)
        errors.add field_name, :invalid
        false
      end

      true
    end

    # Call all validations
    # rubocop:disable Metrics/CyclomaticComplexity
    def nss_validators
      self.class.nss_validations.each do |item|
        next if send(item[:field_name]).blank? || (item[:if] && !check_if(item[:if]))

        case item[:validation]
        when :nif then send(:validate_nss_nif, item[:field_name])
        when :dni then send(:validate_nss_dni, item[:field_name])
        when :cif then send(:validate_nss_cif, item[:field_name])
        when :nie then send(:validate_nss_nie, item[:field_name])
        when :person_nif then send(:validate_nss_person_nif, item[:field_name])
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def check_if(condition)
      return send(condition) if condition.class == String || condition.class == Symbol
      return condition.call if condition.class == Proc

      true
    end

    class << self
      # Call nss validators
      def included(base)
        base.send(:validate, :nss_validators)
      end
    end
  end

  module ClassMethods
    ##
    # Add NIF validation to field
    #
    def validate_nif(field_name, options={})
      add_nss_validation({field_name: field_name, validation: :nif}.merge(options))
    end

    ##
    # Add DNI validation to field
    #
    def validate_dni(field_name, options={})
      add_nss_validation({field_name: field_name, validation: :dni}.merge(options))
    end

    ##
    # Add NIE validation to field
    #
    def validate_nie(field_name, options={})
      add_nss_validation({field_name: field_name, validation: :nie}.merge(options))
    end

    ##
    # Add CIF validation to field
    #
    def validate_cif(field_name, options={})
      add_nss_validation({field_name: field_name, validation: :cif}.merge(options))
    end

    ##
    # Add DNI/NIE validation to field
    #
    def validate_person_nif(field_name, options={})
      add_nss_validation({field_name: field_name, validation: :person_nif}.merge(options))
    end

    ##
    # Add validation
    #
    def add_nss_validation(options)
      @nss_validations ||= []
      @nss_validations.push(options)
    end

    ##
    # Return nss validations
    #
    def nss_validations
      if superclass.methods.include? :nss_validations
        superclass.nss_validations + (@nss_validations || [])
      else
        @nss_validations || []
      end
    end
  end

  ##
  # Adds class methods
  #
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end
end
# rubocop:enable Metrics/ModuleLength
