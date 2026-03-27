Pod::Spec.new do |spec|
  spec.name          = 'AGenUI'
  spec.version       = '0.9.8'
  spec.summary       = 'A Native Renderer for A2UI.'
  spec.description   = 'A Native Renderer for A2UI.'
  spec.homepage      = 'https://github.com/acoder-ai-infra/AGenUI'
  spec.author        = { 'ACoder AI Infra' => 'tengjixiang.ttjx@autonavi.com' }
  spec.license       = { :type => 'MIT', :file => 'LICENSE' }
  spec.source           = { :git => 'https://github.com/airbnb/lottie-ios.git', :tag => s.version.to_s }
  spec.swift_version = '5.0'
  spec.ios.deployment_target = '13.0'

  spec.ios.vendored_frameworks = [
    "Framework/AGenUI.xcframework",
  ]

  spec.dependency 'FlexLayout'
  spec.dependency 'lottie-ios'
  spec.dependency 'MarkdownKit'
  spec.dependency 'DGCharts'

end
