

Pod::Spec.new do |s|

  s.name         = "StfalconContentPicker"
  s.version      = "0.0.1"
  s.ios.deployment_target = '10.0'  
  s.summary      = "Pod uses for fetch media content from user gallery.."
  s.description  = "Highly customizable library that help to fetch photos from library and display they."
  s.homepage     = "https://github.com/stfalcon-studio"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Vitalii Vasylyda" => "vitalii.vasylyda@stfalcon.com" }
  s.source       = { :git =>  "https://github.com/stfalcon-studio/StfalconContentPicker" }
  s.homepage = "https://github.com/stfalcon-studio/StfalconContentPicker"
  s.framework = "UIKit" 
  s.source_files  = "StfalconContentPicker/**/*.{swift}", "StfalconContentPicker/**/*.{xib}"
  s.resource_bundles = {
    'StfalconContentPicker' => [
        'Pod/**/*.xib'
    ]
  }
  s.swift_version = "4.0"

end
