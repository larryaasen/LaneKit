## LaneKit

LaneKit is a Ruby command line app that creates iOS Objective-C models for integration with RestKit.

- [Source code for LaneKit](https://github.com/LarryAasen/LaneKit/zipball/master) from [GitHub](http://github.com).
- Questions? [Stack Overflow](http://stackoverflow.com/questions/tagged/lanekit) is the best place to find answers.

## How To Get Started

1. Install the LaneKit Ruby Gem from RubyGems.org

        $ gem install lanekit
        Successfully installed lanekit-x.x.x
 
2. LaneKit is ready to use

## Example Usage

### Add a new model called Video to an existing Xcode project.
```
$ lanekit generate model video duration:string headline:string image:string
create  Classes/model
create  Classes/model/Video.h
create  Classes/model/Video.m
```

### Add a new model called Contents that contains a list of Videos.
```
$ lanekit generate model contents contents:array:Video
 exist  Classes/model
create  Classes/model/Contents.h
create  Classes/model/Contents.m
```

## Credits

LaneKit was created by [Larry Aasen](https://github.com/larryaasen).

## Contact

Follow Larry Aasen on Twitter [@LarryAasen](https://twitter.com/LarryAasen).

### Creators

[Larry Aasen](https://github.com/larryaasen)  
[@larryaasen](https://twitter.com/larryaasen)

## License

LaneKit is available under the MIT license. See the LICENSE file for more info.
