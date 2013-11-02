require 'yaml'

module LaneKit
  class Lanefile
    def initialize
      @lane_file = File.expand_path('Lanefile')
      if self.exists?
        @contents = load_file
        
        if !File.exists?(self.app_project_path)
          say "Error: cannot find project: #{self.app_project_path}", :red
        end
        
      end
    end

    def exists?
      File.exists?(@lane_file)
    end

    def app_project_name
      @contents['app_project_name']
    end

    def app_project_path
      @contents['app_project_path']
    end

    def app_target_name
      @contents['app_target_name']
    end

    def app_target_tests_name
      @contents['app_target_tests_name']
    end

    private

    def load_file
      YAML.load_file(@lane_file)
    end
  end
end

