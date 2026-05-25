#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_elink_ble.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_elink_ble'
  s.version          = '0.0.1'
  s.summary          = 'ElinkThings BLE SDK plugin.'
  s.description      = <<-DESC
ElinkThings BLE SDK plugin for scanning, connecting, and processing Elink BLE data.
                       DESC
  s.homepage         = 'https://www.elinkthings.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ElinkThings' => 'support@elinkthings.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.frameworks = 'CoreBluetooth'
  s.vendored_frameworks = 'Framework/AILinkBleSDK.framework'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  #
  # AILinkBleSDK.framework is a static archive and includes Objective-C
  # categories such as ELAILinkBleManager+WIFI. The plugin target itself must
  # link with -ObjC so category methods are loaded into flutter_elink_ble.framework.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_elink_ble_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
