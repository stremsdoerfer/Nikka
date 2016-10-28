inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'StreemMapper', '~> 6.1.0'
    pod 'Unbox'
    pod 'Gloss'
    pod 'Unbox'
    pod 'ModelMapper'
    pod 'ObjectMapper'
    pod 'RxSwift', '~> 3.0.0-beta.2'
    pod 'RxCocoa', '~> 3.0.0-beta.2'
end


target 'StreemNetworking' do
    shared_pods
end

target 'StreemNetworkingTests' do
    shared_pods
end

install! 'cocoapods', :deterministic_uuids => false
