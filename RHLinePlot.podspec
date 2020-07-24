Pod::Spec.new do |s|

  s.platforms = { :ios => '13.0' }

  s.name             = 'RHLinePlot'
  s.version          = '0.1.0'
  s.summary          = 'A line plot library inspired by the Robinhood app'
  s.requires_arc     = true
 
  s.description      = <<-DESC
A line plot library inspired by the Robinhood app.
                       DESC
 
  s.homepage         = 'https://github.com/aunnnn/RHLinePlot'
  s.license          = 'MIT'
  s.author           = { 'Wirawit Rueopas' => 'aun.wirawit@gmail.com' }
  s.source           = { :git => 'https://github.com/aunnnn/RHLinePlot.git', :tag => s.version.to_s }
 
  s.source_files     = 'RHLinePlot/*.swift'
  s.swift_version    = '5.0'

  s.ios.deployment_target = '13.0'
 
end