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
  s.module_name               = "StreemNetworking"
  s.default_subspec           = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/*.swift"
    ss.framework  = "Foundation"
  end

  s.subspec "Mapper" do |ss|
    ss.source_files = "Sources/Mapper/*.swift"
    ss.dependency 'StreemNetworking/Core'
    ss.dependency "Mapper", "~> 3.0.0-beta.1", :git => 'https://github.com/JustaLab/mapper.git', :branch => 'swift3'
  end

end
