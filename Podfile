platform :ios, '13.0'

target 'Siksha' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Siksha
  pod 'RealmSwift'
  pod 'SwiftyJSON'
  pod 'NMapsMap'
  pod 'KakaoSDKCommon'
  pod 'KakaoSDKAuth'
  pod 'KakaoSDKUser'
  pod 'GoogleSignIn'
  pod 'BSImagePicker'
  pod 'JTAppleCalendar'
  pod 'SwiftUIPager'

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
