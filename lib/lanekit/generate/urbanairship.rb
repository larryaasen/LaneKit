module LaneKit
  class Generate
    
    include Thor::Actions

    desc "urbanairship", "Generates classes for Urban Airship integration"  
    def urbanairship()
      @podfile_path = File.expand_path('Podfile')
      if !File.exists?(@podfile_path)
        puts "Can't find Podfile #{@podfile_path}"
        return
      end

      pod_name = 'UrbanAirship-iOS-SDK'
      if !LaneKit.does_text_exist_in_file?(@podfile_path, pod_name)
        add_pod__to_podfile pod_name
      
        system "pod install"
      else
        puts "The pod '#{pod_name}' already exists in Podfile"
      end
    end
      
    no_commands do

      def add_pod__to_podfile(pod_name)
        open(@podfile_path, 'a') do |file|
          file.puts "pod '#{pod_name}'"
        end
      end

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
