require 'date'
require 'thor'
require 'xcodeproj'
require 'active_support'
require 'active_support/inflector'
require 'lanekit/version'

module LaneKit
  @@objc_types = {
    "array" => "NSArray *"
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

    desc "generate", "Invoke a code generator"
    long_desc <<-LONGDESC
    Invoke a code generator:\n
    -'model' that generates Objective-C code compatible with RestKit that includes unit tests\n
    -'provider' that generates Objective-C code compatible with RestKit
    LONGDESC
    
    require 'lanekit/generate'
    subcommand "generate", LaneKit::Generate
    
    desc "version", "Display the LaneKit version"
    def version
      puts "LaneKit #{VERSION}"
    end
  end
end
