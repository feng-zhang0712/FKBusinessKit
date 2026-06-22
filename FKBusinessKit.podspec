Pod::Spec.new do |s|
  s.name = 'FKBusinessKit'
  s.version = '0.8.0'
  s.summary = 'FKBusinessKit: iOS business components (Base, TabBarFilter, CellKit) built on FKKit.'
  s.description = <<-DESC
    iOS Swift package for business-oriented UI components such as Base view controller
    foundations, TabBarFilter, and CellKit list/collection cells, depending on FKCoreKit
    and FKUIKit from the FKKit family.
  DESC
  s.homepage = 'https://github.com/feng-zhang0712/FKBusinessKit'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Feng Zhang' => 'https://github.com/feng-zhang0712' }
  s.source = { :git => 'https://github.com/feng-zhang0712/FKBusinessKit.git', :tag => s.version.to_s }
  s.platform = :ios, '15.0'
  s.swift_version = '6.0'
  s.requires_arc = true

  s.source_files = 'Sources/FKBusinessKit/**/*.swift'
  s.dependency 'FKCoreKit', '~> 0.71.0'
  s.dependency 'FKUIKit', '~> 0.71.0'
end
