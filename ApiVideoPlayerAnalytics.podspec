Pod::Spec.new do |s|
  s.name             = 'ApiVideoPlayerAnalytics'
  s.version          = '2.0.0'
  s.summary          = 'The official Swift player analytics for api.video'

  s.homepage         = 'https://github.com/apivideo/api.video-swift-player-analytics'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Ecosystem' => 'ecosystem@api.video' }
  s.source           = { :git => 'https://github.com/apivideo/api.video-swift-player-analytics.git', :tag => "v" + s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*.{swift, plist}'
end
