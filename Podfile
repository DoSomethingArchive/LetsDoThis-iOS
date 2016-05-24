source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

inhibit_all_warnings!

install! 'cocoapods', :deterministic_uuids => false

target 'Lets Do This' do
	pod 'AFNetworking', '2.6.0'
	pod 'AFNetworkActivityLogger', '2.0.4'
    pod 'Parse', '1.8.5'
    pod 'SDWebImage', '3.7.3'
    pod 'SSKeychain', '1.2.3'
    pod 'TSMessages', :git => 'https://github.com/DoSomething/TSMessages.git'
	pod 'Fabric', '1.6.3'
	pod 'Crashlytics', '3.7.0'
    pod 'SVProgressHUD', '1.1.3'
    pod 'GoogleAnalytics', '3.13.0'
    pod 'NewRelicAgent', '5.4.1'
    pod 'NSString+RemoveEmoji', '0.1.0'
    pod 'TapjoySDK', '11.5.1'
    pod 'React', :path => './node_modules/react-native', :subspecs => [
        'Core',
        'RCTImage',
        'RCTNetwork',
        'RCTText',
        'RCTWebSocket',
    ]
end

project 'Lets Do This', 'Thor' => :release, 'Debug' => :debug, 'Release' => :release


