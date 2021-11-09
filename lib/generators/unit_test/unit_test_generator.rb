require 'test_generator'

class UnitTestGenerator < Rails::Generators::NamedBase
  include TestGenerator::TempReader
  include TestGenerator::Association
  include TestGenerator::Validation
  include TestGenerator::Method

  source_root File.expand_path('templates', __dir__)

  def create_unit_test
    p "begin create test"
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

    @denylist = ["updated_at", "created_at", "id"]
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
        unless @denylist.include?(key) or executed_factory_args.include?(key) or (req_attr.include?(key.to_sym) && value == nil)
          if(/(.*)_id$/.match(key))
            klass = eval(@klass)
            # @factory_args.push("#{key.gsub('_id','')}")
            association_name = "#{key.gsub('_id','')}"
            association_class = klass.reflect_on_all_associations(:belongs_to).map{|rel| rel.options[:class_name] if rel.name == association_name.to_sym }.compact.first
            @related_models.push({:model => association_class, :association => association_name })
          else
            val = classes.include?(value.class) ? value : "'#{value}'"
            @factory_args.push("#{key} { #{val} }")
          end
          executed_factory_args.push(key)
        end
      end
    end
    generate_factory(@klass)


    # Generate methods specs
    lines.each do |line|
      # method_name, args, attrs, response = destruct(line)
      klass = eval(@klass)
      method_name = line.keys.first
      args, attrs = line.values.first.values_at('args', 'attrs')
      args = JSON.parse(args)
      attrs = JSON.parse(attrs)
      line_args = {'klass' => klass, 'method' => method_name, 'args' => args, 'attrs' => attrs }
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
        @methods_specs << method_specs(line_args)
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
  
  private
  
  def generate_factory(model_name)
    lines = read_temp_file(model_name)
    related_models = []
    factory_args = []
    executed_factory_args = []
    classes = [Array, TrueClass, FalseClass, Integer, Float, Hash]
    req_attr = required_attr(model_name)
    lines.each do |line|
      # p "CHAVE: #{line.keys}"
      # p "VALOR: #{line.values}"
      attrs = JSON.parse(line.values.first['attrs'])
      attrs.each do |key, value|
        unless @denylist.include?(key) or executed_factory_args.include?(key) or (req_attr.include?(key.to_sym) && value == nil)
          if(/(.*)_id$/.match(key))
            klass = eval(model_name)
            # @factory_args.push("#{key.gsub('_id','')}")
            association_name = "#{key.gsub('_id','')}"
            association_class = klass.reflect_on_all_associations(:belongs_to).map{|rel| rel.options[:class_name] if rel.name == association_name.to_sym }.compact.first
            related_models.push({:model => association_class, :association => association_name })
          else
            val = classes.include?(value.class) ? value : "'#{value}'"
            factory_args.push("#{key} { #{val} }")
          end
          executed_factory_args.push(key)
        end
      end
    end
    template "factory_template.rb", Rails.root.join("spec/factories/BDD/#{model_name.pluralize.downcase}.rb"), {}
    byebug
    related_models.each do |mod| #related_model: {model, association}
      if(mod[:model]) then
        file_name = mod[:model].pluralize.downcase
        # Vê se essa factory já existe (factory.rb)
        if !File.exist?("spec/factories/BDD/#{file_name}.rb") then
          byebug
          # Se não existir, cria
          generate_factory(mod[:model])
        end
        # Se existir, bate palma
      end
    end
    
  end
end
