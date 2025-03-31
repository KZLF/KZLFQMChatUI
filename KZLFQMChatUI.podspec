
#
# Be sure to run `pod lib lint KZLFQMChatUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KZLFQMChatUI'
  s.version          = '1.0.2'
  s.summary          = 'A short description of KZLFQMChatUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/KZLF/KZLFQMChatUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangwnchao' => '1044722126@qq.com' }
  s.source           = { :git => 'https://github.com/KZLF/KZLFQMChatUI.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  
   s.static_framework = true
   s.requires_arc = true
   s.frameworks = 'UIKit'
   s.dependency 'QMChatUICore', '~> 1.0.1'
   s.dependency 'KZLFLineSDK', '~> 1.0.1'
   
  s.subspec 'Cell' do |cell|
    cell.source_files = 'KZLFQMChatUI/Classes/Cell/*.{h,m}'
    cell.dependency 'KZLFQMChatUI/Vendors'
    cell.dependency 'KZLFQMChatUI/Models'
    cell.dependency 'KZLFQMChatUI/View/CommonProblem'
    cell.dependency 'KZLFQMChatUI/View/msgTask'
    cell.dependency 'KZLFQMChatUI/View/QMFormView'
    cell.dependency 'KZLFQMChatUI/View/QMAudio'
    cell.dependency 'KZLFQMChatUI/ViewController/QMImageWithWebPage'
  end
  
  s.subspec 'Models' do |model|
       model.source_files = 'KZLFQMChatUI/Classes/Models/*.{h,m}'
  end
  
  s.subspec 'Vendors' do |vendor|
    vendor.subspec 'EmojiLabel' do |label|
       label.source_files = 'KZLFQMChatUI/Classes/Vendors/EmojiLabel/*.{h,m}'
    end
    vendor.subspec 'Voice' do |voice|
        voice.vendored_libraries = ['KZLFQMChatUI/Classes/Vendors/Voice/*.a']
        voice.source_files = 'KZLFQMChatUI/Classes/Vendors/Voice/*.{h,m}'
    end
      
  end
  
  s.subspec 'View' do |view|
    view.subspec 'CommonProblem' do |problem|
        problem.source_files = 'KZLFQMChatUI/Classes/View/CommonProblem/*.{h,m}'
    end
    view.subspec 'QMAudio' do |audio|
        audio.source_files = 'KZLFQMChatUI/Classes/View/QMAudio/*.{h,m}'
    end
    view.subspec 'QMFileManager' do |manager|
      manager.source_files = "KZLFQMChatUI/Classes/View/QMFileManager/**/*.{h,m}"
   end
    view.subspec 'msgTask' do |task|
        task.source_files = 'KZLFQMChatUI/Classes/View/msgTask/*.{h,m}'
        task.dependency 'KZLFQMChatUI/ViewController/QMImageWithWebPage'
        task.dependency 'KZLFQMChatUI/Models'
        task.dependency 'KZLFQMChatUI/Vendors'
    end
    view.subspec 'QMChatView' do |chatView|
        chatView.source_files = 'KZLFQMChatUI/Classes/View/QMChatView/*.{h,m}'
        chatView.dependency 'KZLFQMChatUI/ViewController/QMImageWithWebPage'
        chatView.dependency 'KZLFQMChatUI/Models'
        chatView.dependency 'KZLFQMChatUI/Cell'
    end
    view.subspec 'QMFormView' do |formView|
        formView.source_files = 'KZLFQMChatUI/Classes/View/QMFormView/*.{h,m}'
        formView.dependency 'KZLFQMChatUI/ViewController/QMImageWithWebPage'
        formView.dependency 'KZLFQMChatUI/View/QMFileManager'
    end
       
  end
  
  s.subspec 'ViewController' do |vc|
    vc.subspec 'QMChatPage' do |chat|
        chat.source_files = 'KZLFQMChatUI/Classes/ViewController/QMChatPage/*.{h,m}'
        chat.dependency 'KZLFQMChatUI/Vendors'
        chat.dependency 'KZLFQMChatUI/Models'
        chat.dependency 'KZLFQMChatUI/Cell'
        chat.dependency 'KZLFQMChatUI/View'
    end
    vc.subspec 'QMImageWithWebPage' do |page|
        page.source_files = 'KZLFQMChatUI/Classes/ViewController/QMImageWithWebPage/*.{h,m}'
    end
        
  end
  
 s.resource = [
    'KZLFQMChatUI/Assets/*.bundle'
 ]
         
   s.pod_target_xcconfig = {'VALID_ARCHS'=>'armv7 x86_64 arm64'}
   
   
   #pod trunk push KZLFQMChatUI.podspec --allow-warnings
end
