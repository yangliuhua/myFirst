Pod::Spec.new do |spec|
  spec.name         = "ComPDFKit_Tools"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of ComPDFKit_Tools."
  spec.description  = <<-DESC
                    "Help you how to use the ComPDFKit.framework"
                   DESC
  spec.homepage     = "https://www.compdf.com/zh-cn"
  spec.license      = 'MIT'
  spec.author       = { "yangliuhua" => "yangliuhua@kdanmobile.com" }
  spec.platform     = :ios, "10.0"
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => 'https://github.com/yangliuhua/myFirst.git'}
  spec.source_files = "myFirst/ComPDFKit_Tools/**", "ComPDFKit_Tools/ComPDFKit_Tools/*.{h, m}", "ComPDFKit_Tools/ComPDFKit_Tools/**/*.{h, m}", "ComPDFKit_Tools/ComPDFKit_Tools/**/**/*.{h, m}", "ComPDFKit_Tools/ComPDFKit_Tools/**/**/**/*.{h, m}"
  spec.ios.resources  = "ComPDFKit_Tools/ComPDFKit_Tools/*.xcassets", "ComPDFKit_Tools/ComPDFKit_Tools/**/*.xcassets", "ComPDFKit_Tools/ComPDFKit_Tools/**/**/*.xcassets", "ComPDFKit_Tools/ComPDFKit_Tools/**/**/**/*.xcassets"
  spec.requires_arc = true
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/ComPDFKit_Tools/**" }

end
