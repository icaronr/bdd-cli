module TestGenerator
  module Validation
    def validations(klass)
      formatted = {}

      klass.validators.group_by(&:kind).each do |kind, validators|
        formatted[kind] = validators.map { |v| { attr: v.attributes.flatten.uniq[0], options: v.options } }
      end

      formatted
    end
    
    def validation_specs(kind, attrs)
      case kind
      when :presence
        attrs.map {|a| "it { should validate_presence_of(:#{a[:attr]}) }" }
      end
    end

    def required_attr(klass_name)
      eval(klass_name)
        .validators                                        
        .grep(ActiveRecord::Validations::PresenceValidator)
        .flat_map(&:attributes)
    end
  end
end
