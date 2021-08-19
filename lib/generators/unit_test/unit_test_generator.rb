require 'test_generator'

class UnitTestGenerator < Rails::Generators::NamedBase
  include TestGenerator::TempReader
  include TestGenerator::Association
  include TestGenerator::Validation
  include TestGenerator::Method

  source_root File.expand_path('templates', __dir__)

  def create_unit_test
    @klass = class_name

    lines = read_temp_file(class_name)
    # p lines
    
    @methods_specs = []
    @validations_specs = []
    @associations_specs = []
    @factory_args = []
    @related_models = []
    executed_factory_args = []

    executed_methods = [] # array to store the executed methods to avoid duplicity
    executed_arguments = {} # hash to store the executed arguments to avoid duplicity

    denylist = ["updated_at", "created_at", "id"]
    # creating the default factory arguments
    
    # lines.first['attrs'].keys.each do |key|
    #   unless denylist.include?(key)
    #     if( /(.*)_id$/.match?(key)) # it is an association
    #       @factory_args.push("#{key.gsub('_id','')}")
    #     else
    #       @factory_args.push("#{key} { \"#{lines.first['attrs'][key]}\" }")
    #     end
    #   end
    # end

    
    classes = [Array, TrueClass, FalseClass, Integer, Float, Hash]
    req_attr = required_attr(@klass)
    lines.each do |line|
      # p "CHAVE: #{line.keys}"
      # p "VALOR: #{line.values}"
      attrs = JSON.parse(line.values.first['attrs'])
      attrs.each do |key, value|
        unless denylist.include?(key) or executed_factory_args.include?(key) or (req_attr.include?(key.to_sym) && value == nil)
          if(/(.*)_id$/.match(key))
            # @factory_args.push("#{key.gsub('_id','')}")
            @related_models.push("#{key.gsub('_id','')}")
          else
            val = classes.include?(value.class) ? value : "'#{value}'"
            @factory_args.push("#{key} { #{val} }")
          end
          executed_factory_args.push(key)
        end
      end
    end

    p @factory_args

    # Generate methods specs
    lines.each do |line|
      klass, method_name, args, attrs, response = destruct(line)
      class_and_method_name = "#{klass}::#{method_name}"
      if executed_methods.include?(class_and_method_name)
        if executed_arguments[class_and_method_name.to_sym].include?(args)
          # do nothing, same test
        else
          # same test with other arguments
          executed_arguments[class_and_method_name.to_sym].push(args)
        end
      else # other test for other method
        executed_methods.push(class_and_method_name)
        executed_arguments[class_and_method_name.to_sym] = []
        p line
        #p method_specs(line)
        #@methods_specs << method_specs(line)
      end
    end

    # Generate association specs
    associations = associations(class_name.camelize.constantize)

    associations.each do |kind, names|
      @associations_specs << association_specs(kind, names)
      p "Kind: #{kind}, Names: #{names}\n"
      #template "factory_template.rb", Rails.root.join("spec/factories/BDD/#{class_name.pluralize.downcase}.rb")
    end
    
    @associations_specs = @associations_specs.flatten.uniq.compact

    # Generate validation specs
    validations = validations(class_name.camelize.constantize)

    validations.each do |kind, attrs|
      @validations_specs << validation_specs(kind, attrs)
    end

    @validations_specs = @validations_specs.flatten.uniq.compact
    template "factory_template.rb", Rails.root.join("spec/factories/BDD/#{class_name.pluralize.downcase}.rb")
    template "model_spec.rb", Rails.root.join("spec/models/BDD/#{class_name.downcase}_spec.rb")
  end
end
