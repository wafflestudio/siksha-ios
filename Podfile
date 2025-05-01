platform :ios, '16.4'

target 'Siksha' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Siksha
  pod 'RealmSwift', '10.6.0'
  pod 'SwiftyJSON', '5.0.0'
  pod 'NMapsMap'
  pod 'GoogleSignIn', '5.0.2'
  pod 'BSImagePicker', '3.3.1'
  pod 'JTAppleCalendar', '8.0.5'
  pod 'Firebase'
  pod 'Firebase/AnalyticsWithoutAdIdSupport'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/RemoteConfig'
  pod 'Kingfisher', '~> 7.0'

end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
				  if config.name == "Debug"
				      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
				  end
		      end
          end
     end
    installer.pods_project.targets.each do |target|
      if target.name == 'NMapsMap'
        `xcrun --sdk iphoneos bitcode_strip -r Pods/NMapsMap/framework/NMapsMap.xcframework/ios-arm64/NMapsMap.framework/NMapsMap -o Pods/NMapsMap/framework/NMapsMap.xcframework/ios-arm64/NMapsMap.framework/NMapsMap`
      end

      if target.name == 'NMapsGeometry'
        `xcrun --sdk iphoneos bitcode_strip -r Pods/NMapsGeometry/framework/NMapsGeometry.xcframework/ios-arm64_armv7/NMapsGeometry.framework/NMapsGeometry -o Pods/NMapsGeometry/framework/NMapsGeometry.xcframework/ios-arm64_armv7/NMapsGeometry.framework/NMapsGeometry`
      end
    end
end
