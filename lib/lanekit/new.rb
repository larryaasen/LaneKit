require 'xcodeproj'

module LaneKit
  class CLI < Thor
    
    include Thor::Actions
    
    desc "new APP_PATH [options]", "Create a new iOS app"
    def new(app_path)
      app_path = app_path.strip
      @app_path = app_path
      @app_path_full = File.expand_path app_path
      @app_name = LaneKit::derive_app_name(app_path)
      
      validate_message = LaneKit.validate_app_name(@app_name)
      if validate_message
        puts "***error: #{validate_message}"
        return
      end

      if File.exists?(@app_path_full)
        puts "Can't create a new LaneKit app in an existing folder: #{@app_path_full}"
        return
      end

      @ios_version = '6.0'
      @original_wd = Dir.pwd
        
      #self.create_app
      self.create_project
    end
    
    no_tasks {
      def create_app
        empty_directory @app_path
        FileUtils.cd(@app_path)
      end
      
      #def create_xcodeproj_project
      #  proj = Xcodeproj::Project.new(File.join(@app_path, "#{@app_name}.xcodeproj"))
      #  app_target = proj.new_target(:application, @app_name, :ios, proj.products_group)
      #  proj.save
      #end
      
      def create_project
        ios_template_name = "lanekit-ios-project"
        source = ios_template_name
        destination = @app_path
        directory(source, destination)
        
        change_filenames(@app_path_full, @app_name, ios_template_name)
      end

      def source_paths
        [@@template_folder]
      end
      
      def change_filenames path, app_name, template_name
        
        Dir.foreach(path) do |file|
          if file == '..' || file == '.'
            next
          end
          
          old_path = File.join path, file
          new_path = old_path
      
          if file.start_with?(template_name)
            new_name = file.sub template_name, app_name
            
            new_path = File.join path, new_name
            FileUtils.mv old_path, new_path
            say_status :rename, new_path, :yellow
          end
      
          if File.directory?(new_path)
            change_filenames new_path, app_name, template_name
          else
            
            begin
              string = IO.read(new_path)
              string = string.gsub!(template_name, app_name)
              if string != nil
                IO.write(new_path, string)
                say_status :update, new_path, :yellow
              end
            
            rescue
            end   
          end
      
        end
      end
        
      
    }
  end
end
