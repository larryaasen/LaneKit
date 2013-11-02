require 'lanekit/lanefile'

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
        
        lanefile_error = self.validate_lanefile
        if lanefile_error
          say lanefile_error, :red
          return
        end

        self.initialize_model
        self.create_model_folders
        self.create_model_files
      end
      
      no_tasks {
        def validate_lanefile
          @lanefile = LaneKit::Lanefile.new
          if !@lanefile.exists?
            return "Error: Cannot find 'Lanefile' in the current folder. Is this a LaneKit generated app folder?"
          end

          @app_project_path = @lanefile.app_project_path
          if !File.exists?(@app_project_path)
            return "Lanefile Error: cannot find project: #{self.app_project_path}"
          end

          if !@lanefile.app_project_name || !@lanefile.app_project_name.length
            return "Lanefile Error: missing app_project_name"
          end

          if !@lanefile.app_target_name || !@lanefile.app_target_name.length
            return "Lanefile Error: missing app_target_name"
          end

          if !@lanefile.app_target_tests_name || !@lanefile.app_target_tests_name.length
            return "Lanefile Error: missing app_target_tests_name"
          end
        end

        def initialize_model
          # Model Base Class
          @model_base_name = "LKModel"
          @model_base_class_name = "LKModel"
          @model_base_file_name = "LKModel"

          @models_folder         = "#{@lanefile.app_project_name}/#{@lanefile.app_project_name}/Models"
          @models_group          = "#{@lanefile.app_project_name}/Models"

          @tests_fixtures_folder = "#{@lanefile.app_project_name}/#{@lanefile.app_project_name}Tests/Fixtures"
          @tests_fixtures_group  = "#{@lanefile.app_project_name}Tests/Fixtures"

          @tests_models_folder   = "#{@lanefile.app_project_name}/#{@lanefile.app_project_name}Tests/Models"
          @tests_models_group    = "#{@lanefile.app_project_name}Tests/Models"

          @tests_resources_folder = "#{@lanefile.app_project_name}/#{@lanefile.app_project_name}Tests/Resources"
          @tests_resources_group  = "#{@lanefile.app_project_name}Tests/Resources"
        end

        def create_model_folders
          empty_directory @models_folder
          empty_directory @tests_fixtures_folder
          empty_directory @tests_models_folder
          empty_directory @tests_resources_folder
        end
      
        def create_model_files
          # 1) Create the Models
          # Create the .h file
          source = "model.h.erb"
          target_file = "#{@model_file_name}.h"
          target = File.join(@models_folder, target_file)
          template(source, target, @@template_opts)
          
          LaneKit.add_file_to_project("Models/"+target_file, @models_group, @app_project_path)

          # Create the .m file
          source = "model.m.erb"
          target_file = "#{@model_file_name}.m"
          target = File.join(@models_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Models/"+target_file, @models_group, @app_project_path, "@all")

          # 2) Create the Model Test Fixtures
          # Create the .h file
          source = "model_fixture.h.erb"
          target_file = "#{@model_fixtures_file_name}.h"
          target = File.join(@tests_fixtures_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Fixtures/"+target_file, @tests_fixtures_group, @app_project_path)

          # Create the .m file
          source = "model_fixture.m.erb"
          target_file = "#{@model_fixtures_file_name}.m"
          target = File.join(@tests_fixtures_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Fixtures/"+target_file, @tests_fixtures_group, @app_project_path, @lanefile.app_target_tests_name)

          # Create the one json file
          source = "model_fixture.json.erb"
          target_file = "#{@model_fixtures_file_name}.one.json"
          target = File.join(@tests_resources_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Resources/"+target_file, @tests_resources_group, @app_project_path, nil)

          # Create the two json file
          source = "model_fixture.json.erb"
          target_file = "#{@model_fixtures_file_name}.two.json"
          target = File.join(@tests_resources_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Resources/"+target_file, @tests_resources_group, @app_project_path, nil)

          # 3) Create the Model Tests
          # Create the .h file
          source = "model_test.h.erb"
          target_file = "#{@model_tests_file_name}.h"
          target = File.join(@tests_models_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Models/"+target_file, @tests_models_group, @app_project_path)

          # Create the .m file
          source = "model_test.m.erb"
          target_file = "#{@model_tests_file_name}.m"
          target = File.join(@tests_models_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Models/"+target_file, @tests_models_group, @app_project_path, @lanefile.app_target_tests_name)
          
          # 4) Create the base model
          # Create the .h file
          source = "model_base.h.erb"
          target_file = "#{@model_base_file_name}.h"
          target = File.join(@models_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Models/"+target_file, @models_group, @app_project_path)

          # Create the .m file
          source = "model_base.m.erb"
          target_file = "#{@model_base_file_name}.m"
          target = File.join(@models_folder, target_file)
          template(source, target, @@template_opts)

          LaneKit.add_file_to_project("Models/"+target_file, @models_group, @app_project_path, "@all")
        end
      }
    end
end

