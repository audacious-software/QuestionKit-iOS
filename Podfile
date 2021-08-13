platform :ios, '9.0'

def required_pods
  pod 'BEMCheckBox', '~> 1.4.1'
  pod 'FSCalendar', '~> 2.8.2'
end

target 'QuestionKit-iOS' do
  use_frameworks!

  required_pods
  
  target 'QuestionKit-iOS-Tests' do
    inherit! :search_paths
    use_frameworks!
    required_pods
  end

  target 'QuestionKit-iOS-UITests' do
    inherit! :search_paths
    use_frameworks!
    required_pods
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end