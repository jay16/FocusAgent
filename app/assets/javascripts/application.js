(function() {
  window.App = {
    showLoading: function() {
      return $(".loading").removeClass("hidden");
    },
    showLoading: function(text) {
      $(".loading").html(text);
      return $(".loading").removeClass("hidden");
    },
    hideLoading: function() {
      $(".loading").addClass("hidden");
      return $(".loading").html("loading...");
    },
    checkboxState: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        return false;
      } else {
        return true;
      }
    },
    checkboxChecked: function(self) {
      return $(self).attr("checked", "true");
    },
    checkboxUnChecked: function(self) {
      return $(self).removeAttr("checked");
    },
    input_operation: function(input, klass) {
      if (App.checkboxState(input)) {
        App.checkboxUnChecked(input);
        return $(klass).removeClass("hidden");
      } else {
        App.checkboxChecked(input);
        return $(klass).addClass("hidden");
      }
    },
    checkboxState1: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        $(self).attr("checked", "true");
        return true;
      } else {
        $(self).removeAttr("checked");
        return false;
      }
    },
    reloadWindow: function() {
      return window.location.reload();
    },
    cpanelNavbarInit: function() {
      var klass, pathname;
      pathname = window.location.pathname;
      klass = "." + pathname.split("/").join("-");
      console.log(klass);
      $(klass).siblings("li").removeClass("active");
      return $(klass).addClass("active");
    },
    resizeWindow: function() {
      var d, e, footer_height, g, main_height, nav_height, w, x, y;
      w = window;
      d = document;
      e = d.documentElement;
      g = d.getElementsByTagName("body")[0];
      x = w.innerWidth || e.clientWidth || g.clientWidth;
      y = w.innerHeight || e.clientHeight;
      nav_height = 80 || $("nav:first").height();
      footer_height = 100 || $("footer:first").height();
      main_height = y - nav_height - footer_height;
      if (main_height > 300) {
        return $("#main").css({
          height: main_height + "px"
        });
      }
    },
    initBootstrapNavbarLi: function() {
      var navbar_lis, navbar_right_lis, pathname;
      pathname = window.location.pathname;
      navbar_right_lis = $("#navbar_right_lis").val() || 1;
      navbar_lis = $(".navbar-nav:first li, .navbar-right li:lt(" + navbar_right_lis + ")");
      return navbar_lis.each(function() {
        var href;
        href = $(this).children("a:first").attr("href");
        if (pathname === href) {
          return $(this).addClass("active");
        } else {
          return $(this).removeClass("active");
        }
      });
    },
    initBootstrapPopover: function() {
      return $("body").popover({
        selector: "[data-toggle=popover]",
        container: "body"
      });
    },
    initBootstrapTooltip: function() {
      return $("body").tooltip({
        selector: "[data-toggle=tooltip]",
        container: "body"
      });
    }
  };

  NProgress.configure({
    speed: 500
  });

  $(function() {
    NProgress.start();
    App.resizeWindow();
    NProgress.set(0.2);
    App.initBootstrapPopover();
    NProgress.set(0.4);
    App.initBootstrapTooltip();
    NProgress.set(0.8);
    App.initBootstrapNavbarLi();
    NProgress.done(true);
    return $("input[type=checkbox]").bind("change", function() {
      if (App.checkboxState(this)) {
        return App.checkboxUnChecked(this);
      } else {
        return App.checkboxChecked(this);
      }
    });
  });

}).call(this);
