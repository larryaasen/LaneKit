module LaneKit
  class Generate < Thor
    
      include Thor::Actions

      desc "model [options] NAME [attributes]", "Generates an Objective-C model for RestKit including unit tests"
      long_desc <<-LONGDESC
      Generates the Objective-C code for a model that is compatible with RestKit. It also generates test fixtures and unit tests.\n
      NAME: the name of the model\n
      [attributes] name:type:relationship, name:type:relationship, ...\n
      where type is [date|integer|string|<class_name>] and relationship (optional) is the name of another class.
      LONGDESC
      
      def model(model_name, *attributes)
        @using_core_data = options[:use_core_data]
        #puts " using Core Data: #{@using_core_data}"
        #puts "            name: #{model_name}"        

        @model_name = LaneKit.derive_model_name(model_name)

        @model_file_name = LaneKit.derive_file_name(@model_name)
        @model_fixtures_file_name = "#{@model_file_name}Fixtures"
        @model_tests_file_name = "#{@model_file_name}Test"

        @class_name = LaneKit.derive_class_name(@model_name)
        
        @attributes = []
        @any_relationships = false
        
        attributes.each {|attribute|
          name, type, relationship = attribute.split(":")
          objective_c_type = LaneKit.objective_c_type(type)
          @attributes << {
            :type => type,
            :name => name,
            :objective_c_type => objective_c_type,
            :relationship => relationship,
            :relationship_fixtures_file_name => "#{relationship}Fixtures",
            :fixture_json => LaneKit.objective_c_type_fixture_json(type),
            :fixture_value => LaneKit.objective_c_type_fixture_value(type),
            :unit_test_assert => LaneKit.objective_c_type_unit_test_assert(@model_name, name, type)
          }
          @any_relationships = relationship ? true : @any_relationships
        }

        self.initialize_model
        self.create_model_folders
        self.create_model_files
        self.update_xcode_project
      end

      def self.source_root
        File.dirname('./')
      end
      
      no_tasks {
        def initialize_model
          # Model Base Class
          @model_base_name = "LKModel"
          @model_base_class_name = "LKModel"
          @model_base_file_name = "LKModel"
          
          @models_folder         = "Classes/Models"
          @tests_fixtures_folder = "Classes/Tests/Fixtures"
          @tests_models_folder   = "Classes/Tests/Models"
          
        end
      
        def source_paths
          LaneKit.template_folders
        end

        def create_model_folders
          empty_directory @models_folder
          empty_directory @tests_fixtures_folder
          empty_directory @tests_models_folder
        end
      
        def create_model_files
          # 1) Create the Models
          # Create the .h file
          source = "model.h.erb"
          target = File.join(@models_folder, "#{@model_file_name}.h")
          template(source, target, @@template_opts)

          # Create the .m file
          source = "model.m.erb"
          target = File.join(@models_folder, "#{@model_file_name}.m")
          template(source, target, @@template_opts)

          # 2) Create the Model Test Fixtures
          # Create the .h file
          source = "model_fixture.h.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.h")
          template(source, target, @@template_opts)

          # Create the .m file
          source = "model_fixture.m.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.m")
          template(source, target, @@template_opts)

          # Create the one json file
          source = "model_fixture.json.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.one.json")
          template(source, target, @@template_opts)

          # Create the two json file
          source = "model_fixture.json.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.two.json")
          template(source, target, @@template_opts)

          # 3) Create the Model Tests
          # Create the .h file
          source = "model_test.h.erb"
          target = File.join(@tests_models_folder, "#{@model_tests_file_name}.h")
          template(source, target, @@template_opts)

          # Create the .m file
          source = "model_test.m.erb"
          target = File.join(@tests_models_folder, "#{@model_tests_file_name}.m")
          template(source, target, @@template_opts)
          
          # 4) Create the base model
          # Create the .h file
          source = "model_base.h.erb"
          target = File.join(@models_folder, "#{@model_base_file_name}.h")
          template(source, target, @@template_opts)

          # Create the .m file
          source = "model_base.m.erb"
          target = File.join(@models_folder, "#{@model_base_file_name}.m")
          template(source, target, @@template_opts)
        end
      }
    end
end

