module TestGenerator
  module Method
    include TestGenerator::Utils
    include TestGenerator::Reflector
    require 'factory_bot_rails'

    def method_specs(line)
      denylist = ["updated_at", "created_at", "id"]
      klass, method_name, args, attrs = destruct(line)
      obj = FactoryBot.create(klass.name.tableize.singularize.to_sym)
      response = reflect(klass, method_name, args, obj)
      attrs_string = "{ "
      attrs.keys.each do |key|
        unless denylist.include?(key)
          unless(/(.*)_id$/.match?(key)) # if it is an association, ignore
            attrs_string.concat("#{key}: '#{attrs[key]}', ")
          end
        end
      end
      final_attrs = attrs_string.reverse.sub(',', '} ').reverse

      "describe '##{method_name}' do
    it 'should' do
      #{klass.name.downcase} = create(:bdd_#{klass.name.downcase})
      expect(#{klass.name.downcase}.#{method_name}(#{args.join(', ')})).to eq #{response}
    end
  end"
    end
  end
end
