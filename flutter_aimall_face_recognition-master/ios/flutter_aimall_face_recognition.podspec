#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_aimall_face_recognition.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aimall_face_recognition'
  s.version          = '1.2.6'
  s.summary          = 'Aimall Face Flutter Plugins.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://gitlab.tqxd.com/flutter/plugins/flutter_aimall_face_recognition'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SimMan' => 'lunnnnul@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'AimallFace', '~> 1.1.0'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
