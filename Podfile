platform :ios, '9.0'

def required_pods
  pod 'BEMCheckBox', '~> 1.4.1'
  pod 'FSCalendar', '~> 2.8.1'
end

target 'QuestionKit' do
  use_frameworks!

  required_pods
  
  target 'QuestionKitTests' do
    inherit! :search_paths
    use_frameworks!
    required_pods
  end
end

