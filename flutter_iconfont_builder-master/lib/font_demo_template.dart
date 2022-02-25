const fontDemoTemplate = r'''

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <title>Flutter IconFont Builder Demo</title>
  <link rel="shortcut icon" href="https://img.alicdn.com/imgextra/i2/O1CN01ZyAlrn1MwaMhqz36G_!!6000000001499-73-tps-64-64.ico" type="image/x-icon"/>
  <link rel="icon" type="image/svg+xml" href="//img.alicdn.com/imgextra/i4/O1CN01EYTRnJ297D6vehehJ_!!6000000008020-55-tps-64-64.svg"/>
  <link rel="stylesheet" href="https://g.alicdn.com/thx/cube/1.3.2/cube.min.css">
  <link rel="stylesheet" href="https://a1.alicdn.com/oss/uploads/2018/12/26/189e7cb0-090f-11e9-80dc-73be9f55f73a.css">
  ${fontCssAndJs}
  <!-- jQuery -->
  <script src="https://a1.alicdn.com/oss/uploads/2018/12/26/7bfddb60-08e8-11e9-9b04-53e73bb6408b.js"></script>
  <script src="https://a1.alicdn.com/oss/uploads/2018/12/26/a3f714d0-08e6-11e9-8a15-ebf944d7534c.js"></script>
  <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
  <style>
    .main .logo {
      margin-top: 0;
      height: auto;
    }

    .main .logo a {
      display: flex;
      align-items: center;
    }

    .main .logo .sub-title {
      margin-left: 0.5em;
      font-size: 22px;
      color: #fff;
      background: linear-gradient(-45deg, #3967FF, #B500FE);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
  </style>
</head>
<body>
  <div class="main">
    <h1 class="logo"><a href="https://www.iconfont.cn/" title="iconfont 首页" target="_blank">
        <span class="sub-title">Flutter IconFont Builder Demo</span>
    </a></h1>
    <div class="article markdown">
        <h2 id="font-class-">如何使用？</h2>
        <p>点击对应图标, 会自动生成 Flutter Icon 代码</p>
        <pre><code class="language-dart">import 'package:your_packages/generated/icon_font.g.dart';</code></pre>
    </div>
    <div class="nav-tabs">
      <ul id="tabs" class="dib-box">
        <li class="dib active"><span>Flutter</span></li>
      </ul>
        <a href="https://pub.youzi.dev/#/packages/detail?name=flutter_iconfont_builder" target="_blank" class="nav-more">查看文档</a>
    </div>
    <div class="tab-container">
      <div class="content unicode" style="display: block;">
          <ul class="icon_lists dib-box">
            ${iconFonts}
          </ul>
      </div>
    </div>
  </div>
  <script type="text/javascript" src="https://unpkg.com/clipboard@2/dist/clipboard.min.js"></script>
  <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
  <script>
  $(document).ready(function () {
      $('.tab-container .content:first').show()
      new ClipboardJS('.code-name', {
          text: function (trigger) {
            Toastify({
              text: `代码已复制到剪切板📋`,
            }).showToast();
            return `Icon(${className}.${trigger.firstChild.nodeValue})`;
          },
        });
        new ClipboardJS('.dib', {
          text: function (trigger) {
            Toastify({
              text: `代码已复制到剪切板📋`,
            }).showToast();
            return `Icon(${className}.${event.target.parentElement.children[1].firstChild.nodeValue})`;
          },
        });
      $('#tabs li').click(function (e) {
        var tabContent = $('.tab-container .content')
        var index = $(this).index()

        if ($(this).hasClass('active')) {
          return
        } else {
          $('#tabs li').removeClass('active')
          $(this).addClass('active')

          tabContent.hide().eq(index).fadeIn()
        }
      })
    })
  </script>
</body>
</html>

''';
