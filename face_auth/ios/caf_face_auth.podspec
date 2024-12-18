#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint face_auth.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'caf_face_auth'
  s.version          = '5.0.0'
  s.summary          = 'A Flutter plugin for Caf.io solution for facial authentication.'
  s.description      = <<-DESC
This Flutter plugin provides functionalities to incorporate facial authentication with proof of life verification and fingerprint authentication technology into your Flutter application. This integration is ideal for enhancing login flows secure way to authenticate users.
                       DESC
  s.homepage         = 'https://www.caf.io/'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Caf.io' => 'services@caf.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform = :ios, '13.0'
                       
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.3.2'
  s.dependency 'Flutter'
  s.dependency 'CafFaceAuth', '6.2.1'
  # Add static framework? s.static_framework = true
end
