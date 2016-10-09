Pod::Spec.new do |s|
  s.name                      = "StreemNetworking"
  s.version                   = "0.1.0"
  s.summary                   = "A Networking library for Swift"
  s.homepage                  = "https://github.com/Justalab/StreemNetworking"
  s.license                   = "Apache License, Version 2.0"
  s.author                    = { "Emilien Stremsdoerfer" => "emstre@gmail.com" }
  s.ios.deployment_target     = "8.0"
  s.source                    = { :git => "https://github.com/Justalab/StreemNetworkinggit", :tag => s.version}
  s.requires_arc              = true
  s.source_files              = "Sources/**/*.swift"
  s.module_name               = "StreemNetworking"
end
