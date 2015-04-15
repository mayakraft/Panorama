Pod::Spec.new do |s|
  s.name             = "PanoramaView"
  s.version          = "1.0.1"
  s.summary          = "sensor-oriented panorama view for iOS"
  s.description      = <<-DESC
                       a dynamic GLKView with a touch and motion sensor interface to align and immerse the perspective inside an equirectangular panorama projection
                       DESC
  s.homepage         = "https://github.com/robbykraft/Panorama"
  s.screenshots     = "https://raw.githubusercontent.com/robbykraft/Panorama/master/readme/azimuth-altitude-pixels.png", "https://raw.githubusercontent.com/robbykraft/Panorama/master/readme/park_small.jpg"
  s.license          = 'MIT'
  s.author           = { "robbykraft" => "robbykraft@gmail.com" }
  s.source           = { :git => "https://github.com/robbykraft/Panorama.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/robbykraft'

  s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Panorama/PanoramaView.m', 'Panorama/PanoramaView.h'

  s.frameworks = 'UIKit', 'OpenGLES', 'GLKit', 'CoreMotion'
end
