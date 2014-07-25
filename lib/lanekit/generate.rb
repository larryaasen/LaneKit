class LaneKit::Generate < Thor
  
  @@lanekit_version = LaneKit::VERSION;
  @@generate_date = Date.today.to_s

  def self.source_root
    File.dirname('./')
  end
  
  desc "pod POD_NAME", "Adds a CocoaPods pod to the Podfile"
  def pod(pod_name)
    pod_name = pod_name.strip
    validate_message = LaneKit.validate_pod_name(pod_name)
    if validate_message
      puts "***error: #{validate_message}"
      return
    end
    
    LaneKit.add_pod_to_podfile(pod_name)
  end

  desc "flurry", "Adds the Flurry pod to the Podfile and updates the LKAppDelegate"
  def flurry()
    lanefile = LaneKit::Lanefile.new
    lanefile_error = LaneKit.validate_lanefile(lanefile)
    if lanefile_error
      say lanefile_error, :red
      return
    end
    controllers_folder = LaneKit.controllers_folder(lanefile)
    app_delegate_file = "#{controllers_folder}/LKAppDelegate.m"

    update_file_add_line(app_delegate_file, 'imports', ['#import "Flurry.h"'])

    text_lines = [
                  '    {',
                  '        // Load the Flurry SDK',
                  '        // TODO: replace your_flurry_key below with your Flurry Key',
                  '        [Flurry startSession:@"your_flurry_key"];',
                  '        [Flurry logEvent:@"applicationDidFinishLaunching"];',
                  '    }',
                  ''
                  ]
    update_file_add_line(app_delegate_file, 'app-did-finish-loading', text_lines)

    pod_name = 'FlurrySDK'
    LaneKit.add_pod_to_podfile(pod_name)
  end

  no_tasks do
    def source_paths
      LaneKit.template_folders
    end

    def update_xcode_project
      xcworkspace_path = ""
      Xcodeproj::Workspace.new_from_xcworkspace(xcworkspace_path)
    end

    def update_file_add_line(filename, template_tag, text_lines)
      added_lines = false
  
      if File.exists?(filename)
        template_tag = "{" + template_tag + "}\n"
        
        insert_into_file filename, :after => template_tag do
          text_lines.join("\n") + "\n"
        end
  
        added_lines = true
      end
  
      ## Open the file to be updated
      #if File.exists?(filename)
      #  found = false
      #  File.readlines(filename).each do |line|
      #    found_template = line.grep(/#{template_tag}/)
      #    # If we found a tag
      #    if found_template.length > 0
      #      # If we are inside a tag
      #      if found
      #        # We are now finished with the tag
      #        break
      #      end
      #      
      #      found = true
      #    end
      #  end
      #  return added_lines
      #else
      #  puts "The file '#{filename}' does not exist"
      #  return added_lines
      #end
      
      return added_lines
    end
  end

  @@template_opts = {
    :command => LaneKit::CLI.command,
    :generate_date => @@generate_date,
    :lanekit_version => @@lanekit_version
  }

  require 'lanekit/generate/model'
  require 'lanekit/generate/provider'
  require 'lanekit/generate/tableviewcontroller'
  require 'lanekit/generate/urbanairship'

  class_option :use_core_data, :type => :boolean, :default => false, :banner => "generate code compatible with Core Data (the default is false)", :aliases => "-c"     # option --use_core_data=true
end
