require 'thor'
require 'xcodeproj'
require 'lanekit/version'
require 'active_support'
require 'active_support/inflector'

module LaneKit
  @@objc_types = {
    array: "NSArray *"
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

  module Generators

    class Generate < Thor
      include Thor::Actions

      desc "model [name] [name:type, name:type, ...] where type is [date|integer|string|<class_name>]", "Generates an Objective-C model for RestKit"
      def model(model_name, *attributes)
        @model_name = LaneKit.derive_model_name(model_name)
        @file_name = LaneKit.derive_file_name(@model_name)
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
            :relationship => relationship
          }
          @any_relationships = relationship ? true : @any_relationships
        }

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
          @models_folder = "Classes/model"
          @template_folder = File.expand_path('../template', __FILE__)
          @using_core_data = false
        end
      
        def source_paths
          [@template_folder]
        end

        def create_model_folders
          empty_directory @models_folder
        end
      
        def create_model_files(model_name)
          # Files are created lowercase
          # Class names are camel case, videodata => VideoData
          
          # Create the .h file
          source = "model.h.erb"
          target = File.join(@models_folder, "#{@file_name}.h")
          template(source,target)

          # Create the .m file
          source = "model.m.erb"
          target = File.join(@models_folder, "#{@file_name}.m")
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
    desc "generate", "Generate a model compatible with RestKit"

    # register(class_name, subcommand_alias, usage_list_string, description_string)
    register(LaneKit::Generators::Generate, "generate", "generate", "Runs a generator")
  end
end
