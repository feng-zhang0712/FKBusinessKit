Pod::Spec.new do |s|
  s.name = 'FKBusinessKit'
  s.version = '0.1.0'
  s.summary = 'FKBusinessKit: app infrastructure for version checks, analytics, i18n, lifecycle, deeplinks, and business utilities.'
  s.description = <<-DESC
    Pure native Swift business capability module for iOS apps. Provides a single entry point
    (FKBusinessKit.shared) for version management, event tracking, in-app localization,
    lifecycle observation, deeplink routing, and common business formatting utilities.
  DESC
  s.homepage = 'https://github.com/feng-zhang0712/FKBusinessKit'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Feng Zhang' => 'https://github.com/feng-zhang0712' }
  s.source = { :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.swift_version = '6.0'
  s.requires_arc = true

  s.source_files = 'Sources/FKBusinessKit/**/*.swift'
end
