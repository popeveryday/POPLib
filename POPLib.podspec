Pod::Spec.new do |s|
s.name             = "POPLib"
s.version          = "0.3.80"
s.summary          = "POPLib is list of common functions for Object-c project."
s.homepage         = "https://github.com/popeveryday/POPLib"
s.license          = 'MIT'
s.author           = { "popeveryday" => "popeveryday@gmail.com" }
s.source           = { :git => "https://github.com/popeveryday/POPLib.git", :tag => s.version.to_s }
s.platform     = :ios, '8.0'
s.requires_arc = true
s.source_files = 'POPLib/Classes/**/*.{h,m,c}'
s.dependency 'PureLayout'
s.dependency 'MBProgressHUD', '~> 1.0'
end
