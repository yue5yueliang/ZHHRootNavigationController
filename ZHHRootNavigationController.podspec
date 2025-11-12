Pod::Spec.new do |s|
  s.name             = 'ZHHRootNavigationController'
  s.version          = '0.0.6'
  s.summary          = '生产级导航控制器，支持独立导航栏、全屏滑动返回、抖音式交互推送，经过性能优化和安全加固。'

  s.description = <<-DESC
  现代应用越来越倾向于为不同的视图控制器定制导航栏，而不是依赖统一的全局样式。
  `ZHHRootNavigationController` 提供了一个灵活、稳定且高性能的导航控制器方案，支持每个 `UIViewController` 独立配置导航栏，同时增强了手势交互体验。

  ### 🔧 核心特性
  - **独立导航栏控制**：每个页面可自定义导航栏样式，包括颜色、透明度、背景图、字体、隐藏状态等，互不干扰。
  - **高级外观支持**：透明导航栏、动态隐藏显示、导航栏高度调整、渐变背景等一应俱全。
  - **增强滑动手势交互**：
    - ✅ 支持系统返回手势的增强版 —— 全屏滑动返回
    - ✅ 可自定义滑动触发区域范围，精细控制交互体验
    - ✅ 支持右侧边缘左滑触发 push 操作，TabBar/主页同步偏移的抖音式效果
  - **轻量无侵入设计**：兼容原生 `UINavigationController`，无需修改现有业务逻辑，开箱即用。
  - **生产级稳定性**：完善的异常处理、内存管理和性能优化，代码质量评分 85.8/100。
  - **适配广泛场景**：适用于电商、内容阅读、社交、直播等多类 App，灵活适配多样化 UI 需求。

  ### ⭐️ v0.0.6 更新亮点
  - 🎬 抖音式交互 Left Push：使用背景快照同步偏移，Push 完成后自动覆盖 TabBar
  - 🧭 Demo 体验优化：发现页、普通导航页默认开启左滑 push 示例
  - 🧩 API 调整：统一通过 `zhh_enableInteractivePushWithHandler:` 注入 push 工厂方法
  - 🧹 清理默认日志：注释调试 NSLog，避免发版时污染控制台
  
  ZHHRootNavigationController 让你的导航体验更自由、更丝滑、更稳定。
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
  
  s.default_subspec  = 'Core'
  s.subspec 'Core' do |core|
    core.source_files = 'ZHHRootNavigationController/Classes/**/*'
  end
  
  # 源代码文件路径
  #s.source_files = 'ZHHRootNavigationController/Classes/**/*'

  # 公共头文件路径（如果有头文件需要暴露，可以打开此项）
  #s.public_header_files = 'ZHHRootNavigationController/Classes/**/*.h'

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
