#
# Be sure to run `pod lib lint PJLinkSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PJLinkSwift'
  s.version          = '0.1.0'
  s.summary          = 'A Swift library for communicating with projectors using the PJLink protocol.'

  s.description      = <<-DESC
  PJLinkSwift is a Swift library for communicating with projectors using the PJLink protocol. 
  It is a successor to PJLinkCocoa, which was written in Objective-C and only supported Class 1
  of the PJLink protocol. This library is 100% Swift and supports both Class 1 and Class 2.
                       DESC

  s.homepage         = 'https://github.com/ehyche/pjlink-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Eric Hyche' => 'ehyche@gmail.com' }
  s.source           = { :git => 'https://github.com/ehyche/pjlink-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ehyche'

  s.ios.deployment_target = '13.0'

  s.source_files = 'PJLinkSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PJLinkSwift' => ['PJLinkSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
