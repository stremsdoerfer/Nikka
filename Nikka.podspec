Pod::Spec.new do |s|
  s.name                      = "Nikka"
  s.version                   = "2.1.0"
  s.summary                   = "A Networking library for Swift"
  s.homepage                  = "https://github.com/Justalab/Nikka"
  s.license                   = "Apache License, Version 2.0"
  s.author                    = { "Emilien Stremsdoerfer" => "emstre@gmail.com" }
  s.ios.deployment_target     = "8.0"
  s.osx.deployment_target     = "10.10"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.source                    = { :git => "https://github.com/Justalab/Nikka.git", :tag => s.version}
  s.requires_arc              = true
  s.default_subspec           = "Core"

  s.subspec "Core" do |ss|
    ss.source_files  = "Sources/*.swift"
    ss.framework  = "Foundation"
  end

  s.subspec "Futures" do |ss|
    ss.source_files = "Sources/Futures/*.swift"
    ss.dependency 'Nikka/Core'
  end

  s.subspec "Rx" do |ss|
    ss.source_files = "Sources/Rx/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
  end

end
