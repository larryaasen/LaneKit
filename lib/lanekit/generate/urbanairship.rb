module LaneKit
  class Generate
    
    include Thor::Actions

    desc "urbanairship", "Generates classes for Urban Airship integration"  
    def urbanairship()
      LaneKit.add_pod_to_podfile('UrbanAirship-iOS-SDK')
    end
      
    no_commands do

      def initialize_provider
        @providers_folder = "Classes/Controllers"
          
        # Resource Provider Base Class
        @provider_base_name = "LKResourceProvider"
        @provider_base_class_name = "LKResourceProvider"
        @provider_base_file_name = "LKResourceProvider"
  
        @provider_file_name = @provider_name
      end

      def create_provider_folders
        empty_directory @providers_folder
      end
  
      def create_provider_files
        # 1) Create the base resource provider
        # Create the .h file
        source = "provider_base.h.erb"
        target = File.join(@providers_folder, "#{@provider_base_file_name}.h")
        template(source, target, @@template_opts)
  
        # Create the .m file
        source = "provider_base.m.erb"
        target = File.join(@providers_folder, "#{@provider_base_file_name}.m")
        template(source, target, @@template_opts)

        # 2) Create the resource provider
        # Create the .h file
        source = "provider.h.erb"
        target = File.join(@providers_folder, "#{@provider_file_name}.h")
        template(source, target, @@template_opts)
  
        # Create the .m file
        source = "provider.m.erb"
        target = File.join(@providers_folder, "#{@provider_file_name}.m")
        template(source, target, @@template_opts)
      end
    end
  end
end
