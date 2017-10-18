inhibit_all_warnings!
use_frameworks!
platform :ios, '8.0'

def shared_pods
    pod 'RxSwift', '~> 4.0.0'
    pod 'RxCocoa', '~> 4.0.0'
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

target 'NikkaOSX' do
    platform :osx, '10.10'
    shared_pods
end

target 'NikkaTests' do
    shared_pods
end

install! 'cocoapods', :deterministic_uuids => false
