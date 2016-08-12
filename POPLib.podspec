Pod::Spec.new do |s|
  s.name             = "POPLib"
  s.version          = "0.1.83"
  s.summary          = "POPLib is list of common functions for Object-c project."
  s.homepage         = "https://github.com/popeveryday/POPLib"
  s.license          = 'MIT'
  s.author           = { "popeveryday" => "popeveryday@gmail.com" }
  s.source           = { :git => "https://github.com/popeveryday/POPLib.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.1'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*.{h,m,c}'
  s.dependency 'MBProgressHUD', '~> 0.9'
end
