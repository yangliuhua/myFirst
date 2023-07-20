
Pod::Spec.new do |spec|
  spec.name         = "MyMasonry"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of compdfkit."
  spec.description  = <<-DESC
                    "A short description of compdfkit."
                   DESC
  spec.homepage     = "https://www.compdf.com/zh-cn"
  spec.license      = 'MIT'

  spec.author       = { "yangliuhua" => "yangliuhua@kdanmobile.com" }

  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"

  spec.source       = { :git => 'https://github.com/yangliuhua/myFirst.git'}


  spec.source_files = 'myFirst/Masonry/*.{h, m}', 'Masonry/*.{h, m}'
  spec.framework    = 'Masonry'
  spec.public_header_files = "myFirst/Masonry/Masonry.h"

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/Masonry/**" }

  spec.ios.deployment_target = '10.0'
  spec.requires_arc = true

end
