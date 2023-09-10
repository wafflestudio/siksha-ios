platform :ios, '13.0'

target 'Siksha' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Siksha
  pod 'RealmSwift', '10.6.0'
  pod 'SwiftyJSON', '5.0.0'
  pod 'NMapsMap', '3.11.0'
  pod 'KakaoSDKCommon', '2.3.2'
  pod 'KakaoSDKAuth', '2.3.2'
  pod 'KakaoSDKUser', '2.3.2'
  pod 'GoogleSignIn', '5.0.2'
  pod 'BSImagePicker', '3.3.1'
  pod 'JTAppleCalendar', '8.0.3'
  pod 'SwiftUIPager', '2.3.0'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
