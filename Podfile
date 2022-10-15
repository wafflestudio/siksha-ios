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

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end
