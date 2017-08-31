Pod::Spec.new do |s|

  s.name                = "TAOverlay"
  s.version             = "2.0.2"
  s.summary             = "TAOverlay is a minimalistic and simple overlay meant to display useful information to the user."
  s.homepage            = "https://github.com/TaimurAyaz/TAOverlay"
  s.screenshots         = "https://raw.githubusercontent.com/TaimurAyaz/TAOverlay/master/screenshot.png"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author              = "Taimur Ayaz"
  s.social_media_url    = "https://twitter.com/taimurayaz"
  s.platform            = :ios, "7.0"
  s.source              = { :git => "https://github.com/TaimurAyaz/TAOverlay.git", :tag => "v2.0.1" }
  s.source_files        = "TAOverlay", "TAOverlay/*.{h,m}"
  s.resources           = 'TAOverlay/TAOverlay.bundle'
  s.requires_arc        = true

end
