# platform
platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'Butterfly' do
  # dynamic frameworks
  use_frameworks!

  # alamofire
  pod 'Alamofire', '~> 5.2'

  # loader
  pod 'NVActivityIndicatorView', '~> 4.8'

  # Floating label text field
  pod 'SkyFloatingLabelTextField', '~> 3.0'

  target 'ButterflyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ButterflyUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end