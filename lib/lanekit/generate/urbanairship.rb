module LaneKit
  class Generate
    
    desc "urbanairship", "Generates classes for Urban Airship integration"  
    def urbanairship()
      LaneKit.add_pod_to_podfile('UrbanAirship-iOS-SDK')
    end
  end
end
