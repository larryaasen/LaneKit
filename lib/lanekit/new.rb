require 'xcodeproj'

module LaneKit
  class CLI < Thor
    
    include Thor::Actions
    
    desc "new APP_PATH [BUNDLE_ID]", "Create a new iOS app"
    def new(app_path, bundle_id=nil)
      app_path = app_path.strip
      @app_path = app_path
      @bundle_id = bundle_id

      @app_name = LaneKit::derive_app_name(app_path)
      validate_message = LaneKit.validate_app_name(@app_name)
      if validate_message
        puts "***error: #{validate_message}"
        return
      end

      @app_path_full = File.expand_path app_path
      if File.exists?(@app_path_full)
        puts "Can't create a new LaneKit app in an existing folder: #{@app_path_full}"
        return
      end
      
      if @bundle_id != nil
        validate_message = LaneKit.validate_bundle_id(@bundle_id)
        if validate_message
          puts "***error: #{validate_message}"
          return
        end
      end
      
      if !LaneKit.gem_available?('cocoapods')
        puts "The Ruby gem cocoapods is not installed. This gem is required by LaneKit.\nInstall command: gem install cocoapods"
        return
      end

      @project_path = File.join @app_path_full, @app_name
      @ios_template_name = "lanekit-ios-project"
      @ios_version = '6.0'
      @original_wd = Dir.pwd
        
      self.create_project
      self.add_gitignore
      self.change_filenames(@app_path_full, @app_name, @ios_template_name)
      self.change_bundle_id(@bundle_id) if @bundle_id != nil
      self.add_cocoapods
      self.clean_workspace
    end

    def self.source_root
      File.dirname('./')
    end

    no_tasks {
      #def create_xcodeproj_project
      #  proj = Xcodeproj::Project.new(File.join(@app_path, "#{@app_name}.xcodeproj"))
      #  app_target = proj.new_target(:application, @app_name, :ios, proj.products_group)
      #  proj.save
      #end
      
      def clean_workspace
        # Remove the extra project that CocoaPods added to the workspace
        workspace_path = File.join(@app_path_full, "#{@app_name}.xcworkspace")
        say_status :clean, workspace_path, :yellow
        workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
        container = "container:#{@app_name}/#{@app_name}.xcodeproj"
        if workspace.include?(container)
          workspace.projpaths.delete(container)
          workspace.save_as(workspace_path)
        end
      end
      
      def change_bundle_id(bundle_id)
        plistbuddy_path = '/usr/libexec/PlistBuddy'
        plist_file = "#{@app_name}-Info.plist"
        info_plist_path = File.join(@project_path, File.join("#{@app_name}", plist_file))
        system("#{plistbuddy_path} -c \"Set :CFBundleIdentifier #{bundle_id}\" #{info_plist_path}")
      end
      
      def add_cocoapods
        Dir.chdir(@project_path) do
          puts "Installing CocoaPods for RestKit"
          system "pod install"
        end
      end
      
      def add_gitignore
        # Download the .gitignore file from GitHub
        require 'net/https'
        ignore_file_uri = URI("http://raw.github.com/github/gitignore/master/Objective-C.gitignore")
        ignore_file_path = File.join(@app_path, ".gitignore")
        say_status :create, ignore_file_path
        
        response = Net::HTTP.start(ignore_file_uri.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          http.get ignore_file_uri.request_uri
        end

        require_text = response.body
        open(ignore_file_path, "wb") do |file|
          file.write(require_text)
        end
        
      end
      
      def create_project
        source = @ios_template_name
        destination = @app_path
        directory(source, destination)
      end

      def source_paths
        LaneKit.template_folders
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
