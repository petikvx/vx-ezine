/*

Copyright Julian Pierer

*/


$(document).ready(function() {

  // Tooltips
  $(".tooltip").tipTip({defaultPosition: "bottom"});
  $(".tooltip_right").tipTip({defaultPosition: "right"});
  $(".tooltip_left").tipTip({defaultPosition: "left"});
  $(".tooltip_top").tipTip({defaultPosition: "top"});

  // Panel Slide
  $('.panel-btn').click(function() {
    if(!$(this).hasClass('opened')) {
      $('.panel-btn').removeClass('closed');
      $('.panel-btn').addClass('opened');
      $('div#panel').animate({bottom: "0px"}, 800);
    }
    else {
      $('.panel-btn').removeClass('opened');
      $('.panel-btn').addClass('closed');
      $('div#panel').animate({bottom: "-450px"}, 800);
    }

  });
  
  // ScrollTo
  $('a[href*=#]').bind("click", function(event) {
    event.preventDefault();
    var ziel = $(this).attr("href");
    
    //console.log(ziel);
    
    if($.browser.opera) {
      var target = 'html';
    }else{
      
      var target = 'html,body';
    }
    
   // console.log(target);
    $(target).animate({
      scrollTop: $(ziel).offset().top
      }, 1000 , function (){location.hash = ziel;
    });
  });
  
});
