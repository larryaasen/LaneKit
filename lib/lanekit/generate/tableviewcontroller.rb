module LaneKit
  class Generate
    
    include Thor::Actions

    desc "tableviewcontroller MODEL_NAME [-r LKFeedCell]", "Generates an Objective-C UITableViewController"
    long_desc <<-LONGDESC
    Generates the Objective-C code for a UITableViewController.\n
    MODEL_NAME: the name of the model used to supply data to the controller. Will create <MODEL_NAME>ViewController class.\n
    -r LKFeedCell: register the LKFeedCell class as the class for use in creating new table cells.
    LONGDESC
    option :register, :required => false, :aliases => "-r", :banner => "register the LKFeedCell class as the class for use in creating new table cells"
    def tableviewcontroller(model_name)
      @using_core_data = options[:use_core_data]
      @register_class = options[:register]
      
      error = self.validate_register_class(@register_class)
      if error
        say error, :red
        return
      end

      @model_name = LaneKit.derive_model_name(model_name)
      @lanefile = LaneKit::Lanefile.new
      lanefile_error = LaneKit.validate_lanefile(@lanefile)
      if lanefile_error
        say lanefile_error, :red
        return
      end
      @app_project_path = @lanefile.app_project_path

      self.initialize_tvc
      self.create_tvc_files
      self.create_register_files
    end
      
    no_commands do

      def initialize_tvc
        @model_class_name = LaneKit.derive_class_name(@model_name)
        @model_file_name = LaneKit.derive_file_name(@model_name)
        @controller_class_name = "#{LaneKit.derive_class_name(@model_name)}ViewController"
        @provider_class_name = "#{LaneKit.derive_class_name(@model_name)}Provider"
        @provider_file_name = @provider_class_name
        @controller_file_name = @controller_class_name
        @controllers_folder = LaneKit.controllers_folder(@lanefile)
        @controllers_group = LaneKit.controllers_group(@lanefile)
        @views_folder = LaneKit.views_folder(@lanefile)
        @views_group = LaneKit.views_group(@lanefile)

        if !@register_class
          @register_class = "UITableViewCell"
        end
      end
      
      def validate_register_class(class_name)
        if class_name
          if class_name.length < 2
            return "class name must be at least two characters long"
          elsif class_name.include? " "
            return "class name cannot include spaces"
          elsif class_name != "LKFeedCell"
            return "class name must be LKFeedCell"
          end
        end
        return nil
      end
  
      def create_tvc_files
        # 1) Create the table view controller
        # Create the .h file
        source = "tvc.h.erb"
        target_file = "#{@controller_file_name}.h"
        target = File.join(@controllers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path)
  
        # Create the .m file
        source = "tvc.m.erb"
        target_file = "#{@controller_file_name}.m"
        target = File.join(@controllers_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Controllers/"+target_file, @controllers_group, @app_project_path, "@all")
      end
      
      def create_register_files
        return if @register_class != "LKFeedCell"

        # 1) Create the LKFeedCell class in the Views group
        # Create the .h file
        source = "#{@register_class}.h.erb"
        target_file = "#{@register_class}.h"
        target = File.join(@views_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Views/"+target_file, @views_group, @app_project_path)

        # Create the .m file
        source = "#{@register_class}.m.erb"
        target_file = "#{@register_class}.m"
        target = File.join(@views_folder, target_file)
        template(source, target, @@template_opts)

        LaneKit.add_file_to_project("Views/"+target_file, @views_group, @app_project_path, "@all")
      end
    end
  end
end
