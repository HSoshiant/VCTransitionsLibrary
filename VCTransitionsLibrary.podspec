
Pod::Spec.new do |s|
  s.name         = 'VCTransitionsLibrary'
  s.version      = '1.6.0'
  s.summary      = 'A collection of interactive iOS 7 custom transitions, including flip, fold, cross-fade and more'
  s.author = {
    'Hossein Karimy' => 'Hossein.Karimy@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/HSoshiant/VCTransitionsLibrary.git',
    :tag => '1.6.0'
  }
  s.license      = {
    :type => 'MIT',
    :file => 'MIT-LICENSE.txt'
  }
  s.source_files = 'AnimationControllers/*.{h,m}', 'InteractionControllers/*.{h,m}' 
  s.homepage = 'https://github.com/HSoshiant/VCTransitionsLibrary'
  s.requires_arc = true
end
