Pod::Spec.new do |s|
  s.name = 'TwilioVerify'
  s.version = '0.4.0'
  s.license = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.summary = 'TwilioVerify'
  s.homepage = 'https://github.com/twilio/twilio-verify-ios'
  s.authors = { 'Twilio' => 'help@twilio.com' }
  s.source = { :git => 'https://github.com/twilio/twilio-verify-ios.git', :tag => s.version }
  s.documentation_url = 'https://twilio.github.io/twilio-verify-ios/latest/'

  s.ios.deployment_target = '10.0'

  s.swift_version = '5.2'

  s.source_files = 'TwilioVerify/TwilioVerify/**/*.swift', 'TwilioVerify/TwilioSecurity/**/*.swift'
end
