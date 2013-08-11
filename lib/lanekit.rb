require 'date'
require 'thor'
require 'xcodeproj'
require 'lanekit/version'
require 'active_support'
require 'active_support/inflector'

module LaneKit
  @@objc_types = {
    "array" => "NSArray *"
  }

  # Model names are lower case
  # "Car" => "car", "Bigbird" => "bigbird"
  def self.derive_model_name(name)
    model_name = name.to_s.downcase
    model_name
  end

  # Objective-C class names are capitalized
  # "car" => "Car", "bigbird" => "Bigbird"
  def self.derive_class_name(name)
    class_name = name.to_s.capitalize
    class_name
  end

  # File names are the same as class names
  def self.derive_file_name(name)
    file_name = name.to_s.capitalize
    file_name
  end
  
  def self.objective_c_type(type_name)
    type = @@objc_types[type_name]
    return type if type
    
    if type_name == "array"
      type = "NSArray *"
    elsif type_name == "date"
      type = "NSDate *"
    elsif type_name == "integer"
      type = "NSNumber *"
    elsif type_name == "string"
      type = "NSString *"
    elsif type_name
      type = type_name + " *"
    else
      type = "id "
    end
    type
  end
  
  def self.objective_c_type_fixture_value(type_name)
    if type_name == "array"
      value = "@[]"
    elsif type_name == "date"
      value = "NSDate.new"
    elsif type_name == "integer"
      value = "[NSNumber numberWithInteger:1]"
    elsif type_name == "string"
      value = "@\"MyString\""
    elsif type_name
      value = "nil"
    else
      value = "nil"
    end
    value
  end
  
  def self.objective_c_type_unit_test_assert(model_name, name, type_name)
    if type_name == "array"
      assert = "STAssertNotNil(#{model_name}.#{name}, @\"#{name} is nil\")"
    elsif type_name == "date"
      assert = "STAssertNotNil(#{model_name}.#{name}, @\"#{name} is nil\")"
    elsif type_name == "integer"
      assert = "STAssertTrue(#{model_name}.#{name}.integerValue == #{self.objective_c_type_fixture_value(type_name)}.integerValue, @\"#{name} not #{self.objective_c_type_fixture_value(type_name)}\")"
    elsif type_name == "string"
      assert = "STAssertTrue([#{model_name}.#{name} isEqualToString:#{self.objective_c_type_fixture_value(type_name)}], @\"#{name} not correct value\")"
    elsif type_name
      assert = "STAssertNotNil(#{model_name}.#{name}, @\"#{name} is nil\")"
    else
      assert = "STAssertNotNil(#{model_name}.#{name}, @\"#{name} is nil\")"
    end
    assert
  end

  module Generators

    class Generate < Thor
      include Thor::Actions

      desc "model NAME [attributes]", "Generates an Objective-C model for RestKit including unit tests"
      long_desc <<-LONGDESC
      Generates the Objective-C code for a model that is compatible with RestKit. It also generates test fixtures and unit tests.\n
      NAME: the name of the model\n
      [attributes] name:type:relationship, name:type:relationship, ...\n
      where type is [date|integer|string|<class_name>] and relationship (optional) is the name of another class.
      LONGDESC
      
      option :use_core_data, :type => :boolean, :default => false, :banner => "generate code compatible with Core Data", :aliases => :c     # option --use_core_data=true
      def model(model_name, *attributes)
        @using_core_data = options[:use_core_data]
        puts "  using Core Data: #{@using_core_data}"

        @model_name = LaneKit.derive_model_name(model_name)

        @model_file_name = LaneKit.derive_file_name(@model_name)
        @model_fixtures_file_name = "#{@model_file_name}Fixtures"
        @model_tests_file_name = "#{@model_file_name}Test"

        @class_name = LaneKit.derive_class_name(@model_name)
        @lanekit_version = VERSION;
        
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
            :fixture_value => LaneKit.objective_c_type_fixture_value(type),
            :unit_test_assert => LaneKit.objective_c_type_unit_test_assert(@model_name, name, type)
          }
          @any_relationships = relationship ? true : @any_relationships
        }
        
        script_name = File.basename($0)
        script_args = ARGV.join(' ')
        
        @command = "#{script_name} #{script_args}"

        self.initialize_stuff
        self.create_model_folders
        self.create_model_files @model_name
        self.update_xcode_project @model_name
      end

      def self.source_root
        File.dirname('./')
      end
      
      no_commands {
        def initialize_stuff
          @model_date = Date.today.to_s
          
          @models_folder         = "Classes/Models"
          @tests_fixtures_folder = "Classes/Tests/Fixtures"
          @tests_models_folder = "Classes/Tests/Models"
          
          @template_folder = File.expand_path('../template', __FILE__)
        end
      
        def source_paths
          [@template_folder]
        end

        def create_model_folders
          empty_directory @models_folder
          empty_directory @tests_fixtures_folder
          empty_directory @tests_models_folder
        end
      
        def create_model_files(model_name)
          # Files are created lowercase
          # Class names are camel case, videodata => VideoData

          # 1) Create the Models
          # Create the .h file
          source = "model.h.erb"
          target = File.join(@models_folder, "#{@model_file_name}.h")
          template(source,target)

          # Create the .m file
          source = "model.m.erb"
          target = File.join(@models_folder, "#{@model_file_name}.m")
          template(source,target)

          # 2) Create the Model Test Fixtures
          # Create the .h file
          source = "model_fixture.h.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.h")
          template(source,target)

          # Create the .m file
          source = "model_fixture.m.erb"
          target = File.join(@tests_fixtures_folder, "#{@model_fixtures_file_name}.m")
          template(source,target)

          # 3) Create the Model Tests
          # Create the .h file
          source = "model_test.h.erb"
          target = File.join(@tests_models_folder, "#{@model_tests_file_name}.h")
          template(source,target)

          # Create the .m file
          source = "model_test.m.erb"
          target = File.join(@tests_models_folder, "#{@model_tests_file_name}.m")
          template(source,target)
        end
  
        def update_xcode_project(model_name)
          xcworkspace_path = ""
          Xcodeproj::Workspace.new_from_xcworkspace(xcworkspace_path)
        end
      }
    end
  end
end

module LaneKit  
  class CLI < Thor
    
    desc "generate", "Invoke a code generator"
    long_desc "Invoke a code generator. There is only one generator so far: 'model' that generates Objective-C code compatible with RestKit that includes unit tests"
    subcommand "generate", LaneKit::Generators::Generate

    # register(class_name, subcommand_alias, usage_list_string, description_string)
    #register(LaneKit::Generators::Generate, "generate", "generate", "Runs a code generator")
    
    desc "version", "Display the LaneKit version"
    
    def version
      puts "LaneKit #{VERSION}"
    end
  end
end
