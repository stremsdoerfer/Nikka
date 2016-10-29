Pod::Spec.new do |s|
  s.name                      = "Nikka"
  s.version                   = "1.0.0"
  s.summary                   = "A Networking library for Swift"
  s.homepage                  = "https://github.com/Justalab/Nikka"
  s.license                   = "Apache License, Version 2.0"
  s.author                    = { "Emilien Stremsdoerfer" => "emstre@gmail.com" }
  s.ios.deployment_target     = "8.0"
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


  s.subspec "StreemMapper" do |ss|
    ss.source_files = "Sources/StreemMapper/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency "StreemMapper"
  end

  s.subspec "StreemMapperFutures" do |ss|
    ss.source_files = "Sources/StreemMapper/Futures/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/StreemMapper'
    ss.dependency "StreemMapper"
  end

  s.subspec "StreemMapperRx" do |ss|
    ss.source_files = "Sources/StreemMapper/Rx/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/StreemMapper'
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
    ss.dependency "StreemMapper"
  end


  s.subspec "Gloss" do |ss|
    ss.source_files = "Sources/Gloss/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency "Gloss"
  end

  s.subspec "GlossFutures" do |ss|
    ss.source_files = "Sources/Gloss/Futures/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/Gloss'
    ss.dependency "Gloss"
  end

  s.subspec "GlossRx" do |ss|
    ss.source_files = "Sources/Gloss/Rx/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/Gloss'
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
    ss.dependency "Gloss"
  end



  s.subspec "Unbox" do |ss|
    ss.source_files = "Sources/Unbox/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency "Unbox"
  end

  s.subspec "UnboxFutures" do |ss|
    ss.source_files = "Sources/Unbox/Futures/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/Unbox'
    ss.dependency "Unbox"
  end

  s.subspec "UnboxRx" do |ss|
    ss.source_files = "Sources/Unbox/Rx/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/Unbox'
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
    ss.dependency "Unbox"
  end



  s.subspec "ObjectMapper" do |ss|
    ss.source_files = "Sources/ObjectMapper/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency "ObjectMapper"
  end

  s.subspec "ObjectMapperFutures" do |ss|
    ss.source_files = "Sources/ObjectMapper/Futures/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/ObjectMapper'
    ss.dependency "ObjectMapper"
  end

  s.subspec "ObjectMapperRx" do |ss|
    ss.source_files = "Sources/ObjectMapper/Rx/*.swift"
    ss.dependency 'Nikka/Core'
    ss.dependency 'Nikka/ObjectMapper'
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
    ss.dependency "ObjectMapper"
  end

end
Contact GitHub API Training Shop Blog About