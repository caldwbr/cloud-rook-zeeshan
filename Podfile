# Uncomment the next line to define a global platform for your project
 platform :ios, ’10.2’

target 'CloudRook' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CloudRook

pod 'FirebaseUI', '~> 1.0’

pod 'Firebase/Core'

pod 'Firebase/Database'

pod 'Firebase/Auth'

pod 'Firebase/Storage'

pod 'GoogleSignIn'

pod 'FBSDKLoginKit'

pod 'Fabric'
pod 'AlamofireImage', '~> 3.1'
pod 'SwiftyJSON'

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
  end