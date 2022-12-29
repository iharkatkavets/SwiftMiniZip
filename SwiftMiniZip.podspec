Pod::Spec.new do |s|
  s.name             = 'SwiftMiniZip'
  s.version          = '0.0.1'
  s.summary          = 'A swift interface for c minizip library'
  s.description      = <<-DESC
A Swift interface for c minizip library. Allow to compress/extract encrypted zip archives.
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
