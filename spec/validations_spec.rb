require 'spec_helper'

RSpec.shared_context "validations" do
  let(:valid_dni) { '29032146M' }
  let(:valid_nie) { 'Y5284410J' }
  let(:valid_cif) { 'R8693558B' }
  let(:valid_cif_number) { 'A89464903' }
  let(:invalid_cif_valid_control_invalid_letter) { 'X52168135' }
  let(:invalid_dni) { valid_dni + 'X' }
  let(:invalid_nie) { valid_dni + 'X' }
  let(:invalid_cif) { valid_dni + 'X' }

  describe 'validation' do
    describe 'dni' do
      it 'with valid' do
        expect(Entity.new(dni: valid_dni).valid?).to be_truthy
      end

      it 'with multiple valid' do
        entity = Entity.new(dni: "#{valid_dni} #{valid_dni}")
        expect(entity.valid?).to be_falsey
        expect(entity.errors[:dni]).not_to be_empty
      end

      it 'with invalid letter' do
        entity = Entity.new(dni: '29032146X')
        expect(entity.valid?).to be_falsey
        expect(entity.errors[:dni]).not_to be_empty
      end

      it 'with invalid' do
        expect(Entity.new(dni: invalid_dni).valid?).to be_falsey
      end
    end

    describe 'nie' do
      it 'with valid' do
        expect(Entity.new(nie: valid_nie).valid?).to be_truthy
      end

      it 'with multiple valid' do
        entity = Entity.new(nie: "#{valid_nie} #{valid_nie}")
        expect(entity.valid?).to be_falsey
        expect(entity.errors[:nie]).not_to be_empty
      end

      it 'with invalid letter' do
        entity = Entity.new(nie: 'X0709831Q')
        expect(entity.valid?).to be_falsey
        expect(entity.errors[:nie]).not_to be_empty
      end

      it 'with invalid' do
        expect(Entity.new(nie: invalid_nie).valid?).to be_falsey
      end
    end

    describe 'cif' do
      context 'when is valid' do
        it 'has control code a letter' do
          expect(Entity.new(cif: valid_cif).valid?).to be_truthy
        end

        it 'has control code a number' do
          expect(Entity.new(cif: valid_cif_number).valid?).to be_truthy
        end
      end

      context 'when is invalid' do
        it 'with valid control_code but invalid first_letter' do
          entity = Entity.new(cif: invalid_cif_valid_control_invalid_letter)
          expect(entity.valid?).to be_falsey
          expect(entity.errors[:cif]).not_to be_empty
        end

        it 'with multiple valid' do
          entity = Entity.new(cif: "#{valid_cif} #{valid_cif}")
          expect(entity.valid?).to be_falsey
          expect(entity.errors[:cif]).not_to be_empty
        end

        it 'with invalid letter' do
          # invalid last number
          entity = Entity.new(cif: 'E93339490')
          expect(entity.valid?).to be_falsey
          expect(entity.errors[:cif]).not_to be_empty
        end

        it 'with invalid' do
          expect(Entity.new(cif: invalid_cif).valid?).to be_falsey
        end
      end
    end

    it 'validate person_nif' do
      expect(Entity.new(person_nif: valid_dni).valid?).to be_truthy
      expect(Entity.new(person_nif: valid_nie).valid?).to be_truthy
      expect(Entity.new(person_nif: valid_cif).valid?).to be_falsey
      expect(Entity.new(person_nif: invalid_dni).valid?).to be_falsey
      expect(Entity.new(person_nif: invalid_nie).valid?).to be_falsey
    end

    it 'validate nif' do
      expect(Entity.new(nif: valid_dni).valid?).to be_truthy
      expect(Entity.new(nif: valid_nie).valid?).to be_truthy
      expect(Entity.new(nif: valid_cif).valid?).to be_truthy
      expect(Entity.new(nif: invalid_dni).valid?).to be_falsey
      expect(Entity.new(nif: invalid_nie).valid?).to be_falsey
      expect(Entity.new(nif: invalid_cif).valid?).to be_falsey
    end
  end

  describe 'functinality' do
    it 'allow heritage' do
      class MyEntity < Entity
      end

      # invalid dni letter (last)
      entity = MyEntity.new(dni: '29032146X')
      expect(entity.valid?).to be_falsey
      expect(entity.errors[:dni]).not_to be_empty
    end
  end
end

describe ValidatesSpanishDocuments do
  context 'when use with Mongoid' do
    class Entity
      include Mongoid::Document
      include ValidatesSpanishDocuments

      field :dni
      field :nie
      field :cif
      field :nif
      field :person_nif

      validate_dni :dni, if: -> { true }
      validate_nie :nie
      validate_cif :cif
      validate_nif :nif
      validate_person_nif :person_nif
    end

    include_context 'validations'
  end

  context 'when use with ActiveModel::Validations' do
    class Entity
      include ActiveModel::Validations
      include ValidatesSpanishDocuments

      validate_dni :dni, if: 'condition'
      validate_nie :nie
      validate_cif :cif
      validate_nif :nif
      validate_person_nif :person_nif

      attr_reader :dni, :nie, :cif, :nif, :person_nif

      def initialize(params)
        @dni = params[:dni]
        @nie = params[:nie]
        @cif = params[:cif]
        @nif = params[:nif]
        @person_nif = params[:person_nif]
      end

      def condition
        true
      end
    end

    include_context 'validations'
  end
end
