require 'xcodeproj'

module LaneKit
  class CLI < Thor
    
    include Thor::Actions
    
    desc "new APP_PATH [options]", "Create a new iOS app"
    def new(app_path)
      # TBD: make sure CocoaPods is installed
      @original_wd = Dir.pwd
      @app_path = app_path
      @app_path_full = File.expand_path app_path
      @app_name = LaneKit::derive_app_name(app_path)
      @ios_version = '6.0'
        
      self.create_app
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
          end
      
          if File.directory?(new_path)
            change_filenames new_path, app_name, template_name
          else
            
            begin
              string = IO.read(new_path)
              string = string.gsub!(template_name, app_name)
              if string != nil
                IO.write(new_path, string)
              end
            
            rescue
            end   
          end
      
        end
      end
        
      
    }
  end
end
