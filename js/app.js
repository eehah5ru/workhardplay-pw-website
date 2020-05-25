(function (self) {
  // const ITERATION_DELAY = 200;

  // var inTOCAdjusting = false;

  // //
  // //
  // // local storage routines
  // //
  // //
  // var withStorage = function (func, rescueFunc) {
  //   if(!_.isUndefined(Storage)) {
  //     return func();
  //   } else {
  //     console.log("storage is not supported");
  //     return rescueFunc();
  //   }
  // };

  // var saveTOCFontSize = function (fontSize) {
  //   return withStorage(
  //     function () {
  //       sessionStorage.tocFontSize = fontSize;
  //     },
  //     function () {
  //       return null;
  //     }
  //   );
  // };

  // var isTOCFontSizeSaved = function () {
  //   return withStorage(
  //     function () {
  //       // console.log("isTOCFontSizeSaved: ",  sessionStorage.tocFontSize, typeof(sessionStorage.tocFontSize), _.isString(sessionStorage.tocFontSize));
  //       return _.isString(sessionStorage.tocFontSize) || _.isNumber(sessionStorage.tocFontSize);
  //     },
  //     function () {
  //       return false;
  //     }
  //   );
  // };

  // var forgetTOCFontSize = function () {
  //   return withStorage(
  //     function () {
  //       sessionStorage.removeItem("tocFontSize");
  //     },
  //     function () {}
  //   );
  // };

  // var getTOCFontSize = function () {
  //   return withStorage(
  //     function () {
  //       return sessionStorage.tocFontSize;
  //     },
  //     function () {
  //       console.log("getting not saved tocFontSize");
  //       return null;
  //     }
  //   );
  // };

  // //
  // //
  // // UI routines
  // //
  // //
  // var isMobile = function () {
  //   var md = new MobileDetect(window.navigator.userAgent);
  //   return md.mobile() || md.phone() || md.tablet();
  // };

  // //
  // //
  // // adjusting
  // //
  // //

  // var hideTOC = function () {
  //   $(".toc-wrapper").addClass("hidden");
  // };

  // var showTOC = function () {
  //   $(".toc-wrapper").removeClass("hidden");
  //   // alert("toc is visible now");
  // };

  // var hasTOCOnPage = function () {
  //   return $(".toc-wrapper").length;
  // };


  // var getTOCWrapperHeight = function () {
  //   return $(".toc-wrapper").height();
  // };

  // var getTOCHeight = function () {
  //   return $(".toc-wrapper .toc").height();
  // };

  // var setTOCItemHeight = function (fontSize) {
  //   $(".toc-wrapper .toc li").css({"font-size": fontSize + "vw"});
  // };

  // var checkFontSize = function (fontSize, callback) {
  //   setTOCItemHeight(fontSize);

  //   callback(null, getTOCHeight() < getTOCWrapperHeight());
  // };


  // var adjustToc = function (minFontSize, maxFontSize) {
  //   var delta = maxFontSize - minFontSize;
  //   var fontSize = minFontSize + delta / 2.0;

  //   // steps are to small to produce significant changes
  //   if (delta < 1.0) {
  //     console.log("end of adjusting ", minFontSize, maxFontSize);
  //     setTOCItemHeight(minFontSize);
  //     saveTOCFontSize(minFontSize);
  //     inTOCAdjusting = false;
  //     return;
  //   }

  //   d3_queue.queue()
  //     .defer(checkFontSize, fontSize)
  //     .await(function (error, isOk) {
  //       if (error) {
  //         console.log("got error while adjusting TOC font: ", error);
  //         return;
  //       }

  //       if (isOk) {
  //         setTimeout(_.partial(adjustToc, fontSize, maxFontSize), ITERATION_DELAY);
  //       }
  //       else {
  //         setTimeout(_.partial(adjustToc, minFontSize, fontSize), ITERATION_DELAY);
  //       }
  //       return;
  //     });

  // };

  // var adjustTocHandler = function () {
  //   if (!hasTOCOnPage()) {
  //     return;
  //   }

  //   if (inTOCAdjusting) {
  //     return;
  //   }

  //   forgetTOCFontSize();
  //   inTOCAdjusting = true;
  //   hideTOC();
  //   setTOCItemHeight(100);
  //   showTOC();
  //   setTimeout(_.partial(adjustToc, 0, 100), 1000);
  // };

  // //
  // //
  // // event handlers
  // //
  // //
  // var onWindowSizeChanged = function () {
  //   if (isMobile()) {
  //     return;
  //   }
  //   // console.log("changed window size");
  //   // alert("changed window size");
  //   adjustTocHandler();
  // };

  // var onOrientationChanged = function () {
  //   if (!isMobile()) {
  //     return;
  //   }

  //   adjustTocHandler();
  // };

  //
  //
  // jquery extensions 
  //
  //
  
  jQuery.fn.random = function() {
    var randomIndex = Math.floor(Math.random() * this.length);  
    return jQuery(this[randomIndex]);
  };  

  //
  //
  // 2018's parameters
  //
  //
  var onClickParameterName = function(self) {
    var descrSelector = "#" + $(self).data("parameter") + "-descr";

    console.log(descrSelector);
    console.log($(descrSelector));
    if ($(self).hasClass("active")) {
      // hide
      $(self).removeClass("active");

      $(descrSelector).addClass("hidden");
    } else {
      // show
      $(self).addClass("active");
      $(descrSelector).removeClass("hidden");
    }

    return false;
  };


  //
  //
  // menu
  //
  //
  var isMenuVisible = false;

  var showMenu = function() {
    // console.log("showing menu - begin: ", isMenuVisible);
    $("#menu").show();
    $("body").addClass("disabled-scroll");
    isMenuVisible = true;
    // console.log("showing menu - end: ", isMenuVisible);
  };

  var hideMenu = function() {
    // console.log("hiding menu - begin: ", isMenuVisible);
    $("#menu").hide();
    $("body").removeClass("disabled-scroll");
    isMenuVisible = false;
    // console.log("hiding menu - end: ", isMenuVisible);
  };

  var toggleMenu = function() {
    if (isMenuVisible) {
      hideMenu();
    }
    else {
      showMenu();
    }
    return false;
  };


  //
  //
  // visibility of long descr in 2017 schedule
  //
  //
  var toggleLongDescrVisibility = function(project) {
    var rootElement = $("[data-project='" + project + "']");

    var h = $(rootElement).find(".long-descr:hidden,.participant-bio:hidden,.participant-name:hidden");
    var v = $(".long-descr:visible,.participant-bio:visible,.participant-name:visible");
    h.show();
    v.hide();

    // var hPB = $(rootElement).find(".participant-bio:hidden");
    // var vPB = $(".participant-bio:visible");
    // hPB.show();
    // vPB.hide();

    // var hPB = $(rootElement).find(".participant-bio:hidden");
    // var vPB = $(".participant-bio:visible");
    // hPB.show();
    // vPB.hide();


    if (_.isEmpty(project)) {
      return;
    }
    console.log("going with empty project: " + project);

    // var project = $(self).parent().parent().data("project");
    var classToAdd = project + "-cover";
    var classToRemove = $(".project-cover").data("classToRemove");

    console.log("project: " + project);
    console.log("classToAdd: " + classToAdd);
    console.log("classToRemove: " + classToRemove);

    if (classToAdd != classToRemove) {
      console.log("adding with-project-cover");
      $(".project-cover").removeClass(classToRemove);
      $(".project-cover").addClass(classToAdd);
      $(".project-cover").data("classToRemove", classToAdd);
      $(".hline").addClass("with-project-cover");
      $("p.day").addClass("with-project-cover");
    }
    else {
      console.log("removing with-project-cover");
      $(".project-cover").removeClass(classToRemove);
      $(".project-cover").data("classToRemove", "");
      $(".hline").removeClass("with-project-cover");
      $("p.day").removeClass("with-project-cover");
    }
    // return false;

    $("#" + project + "-link")[0].click();

    // alert($(self).parent().parent().data("project"));
  };

  var onClickOnShowProjectLonDescriptionLink = function (self) {
    var project =  $(self).parent().parent().data("project");

    toggleLongDescrVisibility(project);
  };

  var addProjectCardBlur = function (self) {
    $("#" + $(self).data("projectId")).removeClass("no-filter");
  };

  var removeProjectCArdBlur = function (self) {
    $("#" + $(self).data("projectId")).addClass("no-filter");
  };

  //
  //
  // mixcloud footer widget
  //
  //
  var initMixcloudFooterWidget = function(self) {
    console.log("initMixcloudFooterWidget: start");
    var promise = Mixcloud.FooterWidget("/work_hard_play_hard/matthieu-levet-rumours-whph_tape_8_side_b/");
    promise.then(function(widget) {
      console.log("initMixcloudFooterWidget: done");
      // Put code that interacts with the widget here e.g.
      widget.events.pause.on(pauseListener);
    });    
  };

  //
  //
  // 2020's flickering terms
  //
  //
  var initFlickeringTerms = function(self) {
    setInterval(function() {
      $("span.flickering-term").each(function(i, el) {
        $(el).find("span.variant.active").removeClass("active");
        $(el).find("span.variant").random().addClass("active");
      });
    }, 250);
  };

  //
  //
  // 2020's closing slot countdown
  //
  //

  var hasCountdown = function(el) {
    if (_.isEmpty($(el).data("closingTime"))) {
      return false;
    }
    return true;
  };

  var getCountdownDistance = function(self) {
    var now = new Date().getTime();
    var closingTime = new Date($(self).data("closingTime")).getTime();

    return closingTime - now;
  };

  var isCountdownExpired = function(self) {
    return (getCountdownDistance(self) < 0.0);
  };
  
  var tickCountdown = function(self) {
    if (isCountdownExpired(self)) {
      $(self).html("💥");
      return;
    }
    
    var distance = getCountdownDistance(self);


    // Time calculations for days, hours, minutes and seconds
    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    var seconds = Math.floor((distance % (1000 * 60)) / 1000);
    
    var formatted = days + ":" + hours + ":" + minutes + ":" + seconds;

    $(self).html(formatted);
  };
  
  var initSlotCountdown = function() {
    $(".invitation span.countdown").each(function(i, el) {
      if (!hasCountdown(el)) {
        return;
      }

      if (isCountdownExpired(el)) {
        $(el).html("💥");        
        return;
      }

      console.log(getCountdownDistance(el));
      
      setInterval(function() {
        tickCountdown(el);
      }, 1000);
      
    });
  };
  
  //
  //
  // init
  //
  //
  $(document).ready(function () {
    // $(document).foundation();
    console.log("init menu");
    $("#menu-sign").click(function() {
      toggleMenu();
    });

    //
    // 2018-2020 paramaters
    //
    $("span.parameter-descr").addClass("hidden");
    $("a.parameter-name").click(function(e) {
      return onClickParameterName(e.target);
    });

    //
    // flickering terms
    //
    initFlickeringTerms();

    //
    // slot countdown
    //
    initSlotCountdown();
    
    //
    // schedule projects descriptions
    //
    $("p.descr span").click(function(e) {
      // alert("aaa");
      onClickOnShowProjectLonDescriptionLink(e.target);
    });

    $(".project-card").mouseenter(function(e) {
      removeProjectCArdBlur(e.target);
    });

    $(".project-card").mouseleave(function(e) {
      addProjectCardBlur(e.target);
    });

    window.setTimeout(
      function() {
        toggleLongDescrVisibility(window.location.hash.replace(/#/, ''));
        var projectName = window.location.hash.replace(/#/, '');
        if (_.isEmpty(projectName)) {
          return;
        }
        window.location.hash = projectName;        
        $("#" + projectName + "-link")[0].click();
        // $("#" + window.location.hash.replace(/#/, '') + "-link").click();

      },
      500
    );

    // initMixcloudFooterWidget();
    
    // $("li.project-card-box").map(function() {
    //   var r = Math.random() * (15 - (-15)) + (-15);
    //   var rblur = Math.random() * 2;
    //   $(this).css("transform", "rotate3d(1, 1, 0, " + r +"deg)")
    //     .css("filter", "blur(" + rblur + "px)");
    // });
  });


  // $(window).on("orientationchange", onOrientationChanged);
  // $(window).resize(onWindowSizeChanged);

})(this);
