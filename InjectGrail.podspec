#
# Be sure to run `pod lib lint InjectGrail.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InjectGrail'
  s.version          = '0.2.6'
  s.summary          = 'Holy Grail of  Swift Injection frameworks for iOS and MacOs.'
  s.description      = <<-DESC
Tired of injection framework that puts everything in one big bag of dependecy resolvers? This framework might be good for you.
                       DESC

  s.homepage         = 'https://github.com/SwingDev/ios-inject-grail'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Łukasz Kwoska' => 'lukasz.kwoska@swing.dev' }
  s.source           = { :git => 'https://github.com/SwingDev/ios-inject-grail.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Szakulus'

  s.ios.deployment_target = '9.0'
  s.swift_versions = '5.0'

  s.source_files = 'InjectGrail/Classes/**/*.{swift}'
  s.preserve_paths          = 'Scripts', 'Templates'
  s.dependency 'Sourcery', '~> 2.1.2'
end
