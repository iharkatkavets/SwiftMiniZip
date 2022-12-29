#
# Be sure to run `pod lib lint SwiftMiniZip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftMiniZip'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SwiftMiniZip.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Ihar Katkavets/SwiftMiniZip'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ihar Katkavets' => 'iharkatkavets@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/Ihar Katkavets/SwiftMiniZip.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'SwiftMiniZip/Classes/**/*.{swift,h,c}'
  s.public_header_files = 'SwiftMiniZip/Classes/*.h'
  s.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Classes/**/minizip/**','LIBRARY_SEARCH_PATHS' => '$(SRCROOT)/Classes/'}
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.7' }
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/' }
  s.libraries = 'z'
end
