module LaneKit
  class Generate
    
    include Thor::Actions

    desc "provider [options] NAME MODEL_NAME [URL]", "Generates an Objective-C resource provider for RestKit including unit tests"
    long_desc <<-LONGDESC
    Generates the Objective-C code for a resource provider that is compatible with RestKit. It also generates test fixtures and unit tests.\n
    NAME: the name of the provider\n
    MODEL_NAME: the name of the model\n
    URL: the HTTP URL to the data\n
    LONGDESC
  
    def provider(name, model_name, url=nil)
      @using_core_data = options[:use_core_data]
      #puts " using Core Data: #{@using_core_data}"
      #puts "            name: #{name}"        
      #puts "      model_name: #{model_name}"        
      #puts "             url: #{url}"

      @provider_name = "#{LaneKit.derive_class_name(name)}Provider"
      @model_name = LaneKit.derive_model_name(model_name)
      @model_class_name = LaneKit.derive_class_name(@model_name)
      @model_file_name = LaneKit.derive_file_name(@model_name)
      @provider_url = url

      @lanefile = LaneKit::Lanefile.new
      lanefile_error = LaneKit.validate_lanefile(@lanefile)
      if lanefile_error
        say lanefile_error, :red
        return
      end
      @app_project_path = @lanefile.app_project_path

      self.initialize_provider
      self.create_provider_folders
      self.create_provider_files
    end
      
    no_commands do

      def initialize_provider
        # Resource Provider Base Class
        @provider_base_name = "LKResourceProvider"
        @provider_base_class_name = "LKResourceProvider"
        @provider_base_file_name = "LKResourceProvider"
  
        @provider_file_name = @provider_name

        @providers_folder = LaneKit.controllers_folder(@lanefile)
        @controllers_group = LaneKit.controllers_group(@lanefile)
      end

      def create_provider_folders
        empty_directory @providers_folder
      end
  
      def create_provider_files
        # 1) Create the base resource provider
        # Create the .h file
        source = "provider_base.h.erb"
        target_file = "#{@provider_base_file_name}.h"
        target = File.join(@providers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path)
  
        # Create the .m file
        source = "provider_base.m.erb"
        target_file = "#{@provider_base_file_name}.m"
        target = File.join(@providers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path, "@all")

        # 2) Create the resource provider
        # Create the .h file
        source = "provider.h.erb"
        target_file = "#{@provider_file_name}.h"
        target = File.join(@providers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path)
  
        # Create the .m file
        source = "provider.m.erb"
        target_file = "#{@provider_file_name}.m"
        target = File.join(@providers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path, "@all")
      end
    end
  end
end
