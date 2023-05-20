# 为生化危机4Remake设计的"生命值(血条)"模组 简体中文翻译版

语言：  
[English](README.md) | **简体中文**  

***

为生化危机4Remake设计的"生命值(血条)"模组。  

![health_bars_2](https://user-images.githubusercontent.com/30152047/226180919-2ddaacc2-f8c7-4688-8ec0-1958da87f91a.png)


# 原始下载链接  
* **[Nexus Mods](https://www.nexusmods.com/residentevil42023/mods/84)**  

# 模组前置需求  
1. [REFramework](https://www.nexusmods.com/residentevil42023/mods/12) (v1.460或者更高版本);
2. [REFramework Direct2D](https://www.nexusmods.com/residentevil42023/mods/83) (v0.4.0或者更高版本).

# 如何安装？:
1. 先安装[REFramework](https://www.nexusmods.com/residentevil42023/mods/12);
2. (可选，汉化版必须) 再安装 [REFramework Direct2D](https://www.nexusmods.com/residentevil42023/mods/83);
3. 下载这些mod:
    * 官方所发布的下载地址是 [Nexus Mods](https://www.nexusmods.com/residentevil42023/mods/84);
    * 每晚构建版本可以在[此存储库](https://github.com/GreenComfyTea/RE4-Health-Bars)中获取，可能包含错误功能、屏幕上的调试信息、错误和可能需要最新的[每晚构建版本](https://github.com/praydog/REFramework-nightly/releases)的[REFramework](https://www.nexusmods.com/residentevil42023/mods/12)。请谨慎使用！  
4. 从存档中提取该模组，并将其放置在《生化危机4》文件夹中。最终路径应该如下所示：`/RESIDENT EVIL 4 BIOHAZARD RE4/reframework/autorun/Health_Bars.lua`。(汉化版还有一个字体文件。)
  
# 如何编译?
**前置软件: **
+ [lua-amalg](https://github.com/siffiejoe/lua-amalg)    
+ [Lua 5.4+](https://www.lua.org/)  
使用这些软件来编译脚本。  
  
**编译命令示例:(注意：将"lua54.exe”、“amalg.lua”和“Health_Bars.lua"的路径替换为您的路径):**  

`"D:\Programs\Lua Amalg\lua54.exe" amalg.lua -o Health_Bars_precompiled.lua -d -s "E:\GitHub\RE4-Health-Bars\reframework\autorun\Health_Bars.lua" Health_Bars.bar_customization Health_Bars.config Health_Bars.customization_menu Health_Bars.drawing Health_Bars.enemy_handler Health_Bars.gui_handler Health_Bars.label_customization Health_Bars.player_handler Health_Bars.screen Health_Bars.singletons Health_Bars.time Health_Bars.utils Health_Bars.language`
  
# 贡献者名单  
+ **GreenComfyTea** - 模组的创建者及其主要贡献者。  
+ **Coconutat** - 简体中文翻译者。  
  
***
# 给予作者支持(仅模组作者，建议您阅读原始语言版本，这里仅供参考)：

如果您喜欢这个模组，您可以通过捐款来支持我！我会十分感激！无论您是否决定支持我，都感谢您使用这个模组！

 <a href="https://streamelements.com/greencomfytea/tip">
  <img alt="Qries" src="https://panels.twitch.tv/panel-48897356-image-c6155d48-b689-4240-875c-f3141355cb56">
</a>
<a href="https://ko-fi.com/greencomfytea">
  <img alt="Qries" src="https://panels.twitch.tv/panel-48897356-image-c2fcf835-87e4-408e-81e8-790789c7acbc">
</a>
