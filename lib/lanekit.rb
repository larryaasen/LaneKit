require 'date'
require 'thor'
require 'xcodeproj'
require 'active_support'
require 'active_support/inflector'
require 'lanekit/version'
require 'lanekit/lanefile'

module LaneKit
  @@objc_types = {
    "array" => "NSArray *"
  }
  @template_folder = File.expand_path('../template', __FILE__)

  def self.template_folders
    [@template_folder]
  end
  
  # Adds a file to a group in an Xcode project
  # For example: LaneKit.add_file_to_project('Message.m', 'Models', 'SportsFrames', 'SportsFrames')
  def self.add_file_to_project(file_name, group_name, project_path, target_name=nil)
    # Open the existing Xcode project
    project = Xcodeproj::Project.open(project_path)
    
    #puts "group_name: #{group_name}"
    #puts "groups: #{project.groups}"
    #puts "group: #{project[group_name]}"
    
    group = project[group_name]
    
    # Avoid duplicates
    ref = group.find_file_by_path(file_name)
    return if ref
     
    # Add a file to the project in the main group
    file = group.new_reference(file_name)

    if target_name == "@all"
      # Add the file to the main target
      
      project.targets.each do |target|
        target.add_file_references([file])
      end
    elsif target_name
      # Add the file to the main target
      
      unless target = project.targets.find { |target| target.name == target_name }
        raise ArgumentError, "Target by name `#{target_name}' not found in the project."
      end
      
      target.add_file_references([file])
    end
     
    # Save the project file
    project.save
  end  

  # Adds a pod file line to a CocoaPods Podfile
  def self.add_pod_to_podfile(pod_name)
    podfile_path = File.expand_path('Podfile')
    if !File.exists?(podfile_path)
      puts "Can't find Podfile #{podfile_path}"
      return
    end

    if !self.does_text_exist_in_file?(podfile_path, pod_name)
      open(podfile_path, 'a') do |file|
        file.puts "pod '#{pod_name}'"
      end
    
      system "pod install"
    else
      puts "The pod '#{pod_name}' already exists in Podfile"
    end
  end

  # Returns an app name from a folder path.
  # "Tracker" => "Tracker", "~/Projects/Runner" => "Runner"
  def self.derive_app_name(app_path)
    app_name = File.basename(app_path).to_s
  end

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

  def self.does_text_exist_in_file?(file_path, text)
    found_text = open(file_path) { |f| f.grep(/#{text}/) }
    exists = found_text && found_text.count > 0
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
  
  def self.objective_c_type_fixture_json(type_name)
    if type_name == "array"
      value = "[]"
    elsif type_name == "date"
      value = "03/01/2012"
    elsif type_name == "integer"
      value = "1"
    elsif type_name == "string"
      value = "MyString"
    elsif type_name
      value = ""
    else
      value = ""
    end
    value
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
  
  def self.validate_app_name(app_name)
    if app_name.length < 2
      return "app name must be at least two characters long"
    elsif app_name.include? " "
      return "app name cannot include spaces"
    end
    return nil
  end
  
  def self.validate_pod_name(pod_name)
    if pod_name.length < 2
      return "pod name must be at least two characters long"
    elsif pod_name.include? " "
      return "pod name cannot include spaces"
    end
    return nil
  end
  
  def self.validate_bundle_id(bundle_id)
    if bundle_id.length < 2
      return "bundle id must be at least two characters long"
    elsif bundle_id.include? " "
      return "bundle id cannot include spaces"
    end
    return nil
  end
  
  def self.gem_available?(gemname)
    if Gem::Specification.methods.include?(:find_all_by_name) 
       not Gem::Specification.find_all_by_name(gemname).empty?
     else
       Gem.available?(gemname)
     end
  end

  def self.validate_lanefile(lanefile)
    if !lanefile.exists?
      return "Error: Cannot find 'Lanefile' in the current folder. Is this a LaneKit generated app folder?"
    end
  
    app_project_path = lanefile.app_project_path
    if !File.exists?(app_project_path)
      return "Lanefile Error: cannot find project: #{app_project_path}"
    end
  
    if !lanefile.app_project_name || !lanefile.app_project_name.length
      return "Lanefile Error: missing app_project_name"
    end
  
    if !lanefile.app_target_name || !lanefile.app_target_name.length
      return "Lanefile Error: missing app_target_name"
    end
  
    if !lanefile.app_target_tests_name || !lanefile.app_target_tests_name.length
      return "Lanefile Error: missing app_target_tests_name"
    end
  end

  def self.controllers_folder(lanefile)
    "#{lanefile.app_project_name}/#{lanefile.app_project_name}/Controllers"
  end

  def self.controllers_group(lanefile)
    "#{lanefile.app_project_name}/Controllers"
  end

  def self.views_folder(lanefile)
    "#{lanefile.app_project_name}/#{lanefile.app_project_name}/Views"
  end

  def self.views_group(lanefile)
    "#{lanefile.app_project_name}/Views"
  end
end

module LaneKit
  class CLI < Thor
    script_name = File.basename($0)
    script_args = ARGV.join(' ')
    
    @command = "#{script_name} #{script_args}"

    no_commands do    
      def self.command
        @command
      end
    end
    
    map ["-v", "--version"] => :version

    require 'lanekit/generate'
    desc "generate", "Invoke a code generator"
    long_desc <<-LONGDESC
    Invoke a code generator:\n
    -'model' that generates Objective-C code compatible with RestKit that includes unit tests\n
    -'provider' that generates Objective-C code compatible with RestKit
    LONGDESC
    subcommand "generate", LaneKit::Generate

    require 'lanekit/new'
    
    desc "version", "Display the LaneKit version"
    def version
      puts "LaneKit #{VERSION}"
    end
  end
end
