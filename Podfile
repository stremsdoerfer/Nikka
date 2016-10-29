inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'StreemMapper'
    pod 'Unbox'
    pod 'Gloss'
    pod 'Unbox'
    pod 'ModelMapper'
    pod 'ObjectMapper'
    pod 'RxSwift', '~> 3.0.0'
    pod 'RxCocoa', '~> 3.0.0'
end


target 'NikkaIOS' do
    shared_pods
end

target 'NikkaTvOS' do
    platform :tvos, '9.0'
    shared_pods
end

target 'NikkaWatchOS' do
    platform :watchos, '2.0'
    shared_pods
end

target 'NikkaTests' do
    shared_pods
end

install! 'cocoapods', :deterministic_uuids => false
