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
    var h = $(rootElement).find("p.long-descr:hidden");
    var v = $("p.long-descr:visible");

    h.show();
    v.hide();

    // var project = $(self).parent().parent().data("project");
    var classToAdd = project + "-cover";
    var classToRemove = $(".project-cover").data("classToRemove");

    if (classToAdd != classToRemove) {
      $(".project-cover").removeClass(classToRemove);
      $(".project-cover").addClass(classToAdd);
      $(".project-cover").data("classToRemove", classToAdd);
      $(".hline").addClass("with-project-cover");
      $("p.day").addClass("with-project-cover");
    }
    else {
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
  // init
  //
  //
  $(document).ready(function () {
    // $(document).foundation();
    console.log("init menu");
    $("#menu-sign").click(function() {
      toggleMenu();
    });

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
        $("#" + window.location.hash.replace(/#/, '') + "-link")[0].click();
        // $("#" + window.location.hash.replace(/#/, '') + "-link").click();
        window.location.hash = window.location.hash.replace(/#/, '');
      },
      500
    );

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
