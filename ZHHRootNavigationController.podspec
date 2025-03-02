Pod::Spec.new do |s|
  s.name             = 'ZHHRootNavigationController'
  s.version          = '0.0.1'
  s.summary          = '一个支持每个视图控制器拥有独立导航栏的自定义导航控制器。'

  # 详细描述 pod 的功能、用途及特点
  s.description      = <<-DESC
  现代应用越来越倾向于为不同的视图控制器定制导航栏，而不是使用统一的全局导航栏。
  `ZHHRootNavigationController` 通过提供一个灵活、可扩展的导航控制器，让每个 `UIViewController` 拥有独立的导航栏设置。
  
  ### **主要特性**
  - **独立导航栏管理**：每个 `UIViewController` 可以独立设置导航栏样式，如颜色、背景图片、透明度等，不影响全局导航栏。
  - **高级外观控制**：支持透明导航栏、渐变背景、动态隐藏、导航栏高度调整等。
  - **与系统兼容**：完全兼容 `UINavigationController`，支持原生返回手势，`push/pop` 过渡动画流畅自然。
  - **轻量级集成**：无侵入性设计，适配现有项目架构，无需额外改动原有代码。
  - **适用场景广泛**：电商、社交、工具类应用等，均可通过该组件增强 UI 交互体验。

  让你的应用更加灵活，适应不同的 UI 需求！
  DESC

  # 项目主页（GitHub地址或文档链接）
  s.homepage         = 'https://github.com/yue5yueliang/ZHHRootNavigationController'

  # 许可证
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  # 作者信息
  s.author           = { '桃色三岁' => '136769890@qq.com' }

  # 代码托管地址
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHRootNavigationController.git', :tag => s.version.to_s }

  # 支持的最低 iOS 版本
  s.ios.deployment_target = '13.0'

  # 源代码文件路径
  s.source_files = 'ZHHRootNavigationController/Classes/**/*'

  # 公共头文件路径（如果有头文件需要暴露，可以打开此项）
  s.public_header_files = 'ZHHRootNavigationController/Classes/**/*.h'

  # 资源文件（如图片、xib 等）
  # s.resource_bundles = {
  #   'ZHHRootNavigationController' => ['ZHHRootNavigationController/Assets/*.png']
  # }

  # 需要的系统框架
  s.frameworks = 'UIKit'

  # 需要的系统库（如果有的话）
  # s.libraries = 'sqlite3', 'z'

  # 依赖的第三方库（如果有的话）
  # s.dependency 'SomeLibrary', '~> 1.2.3'

  # 是否支持 ARC
  s.requires_arc = true
end
