#
# Be sure to run `pod lib lint iONess.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iONess'
  s.version          = '2.0.1'
  s.summary          = 'iOS Network Session'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  iONess is HTTP Request Helper for iOS platform used by HCI iOS App
                       DESC

  s.homepage         = 'https://github.com/oss-homecredit-id/iONess'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nayanda' => 'hainayanda@outlook.com' }
  s.source           = { :git => 'https://github.com/oss-homecredit-id/iONess.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'iONess/Classes/**/*'
  
  # s.resource_bundles = {
  #   'iONess' => ['iONess/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Ergo', '~> 1.0.3'
  s.swift_version = '5.1'
end
