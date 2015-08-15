function loadPP2() {
    if(Math.round(Math.random()*100)>5)
        return;
    showPP2((Math.round(Math.random()*170)+40)*900);
}
function showPP2(time) {
    var e = document.createElement('img');
    
    e.setAttribute('src', '//files.everypony.ru/tabun/pinkamena.png');
    e.setAttribute('style', 'display:none;');
    document.getElementsByTagName('body')[0].appendChild(e);
    window.setTimeout(function(){
        e.setAttribute('style', 'display:block;position:fixed;left:0px;bottom:0px;z-index:100;height:100%;');
        window.setTimeout(function(){
            document.getElementsByTagName('body')[0].removeChild(e);
        }, 1000);
    }, time);
}
function getCook(name) {
    var array = document.cookie.split('; '), i = array.length
            while(i--) if(array[i].split('=')[0] == escape(name))
                return unescape(array[i].split('=')[1]);
            return false;
}
function hideImg() {
    if(!getCook("debug")) return;
    var xpath = document.evaluate(".//img", document, null, 6, null);
            for(var i=0;i<xpath.snapshotLength;i++) {
                xpath.snapshotItem(i).style.opacity = '0.02';
                xpath.snapshotItem(i).addEventListener('mouseout', function(el){
                    el.target.style.opacity = '0.02';
                }, false);
                xpath.snapshotItem(i).addEventListener('mouseover', function(el){
                    el.target.style.opacity = '1.0';
                },false);
                }
}
// OnLoad
$(function(){
	//Обработка нажатия на кнопку "Wide Mode"
	$("#widemode-switch").click(function(){
		$('body').toggleClass('widemode');
	});
	//Обработка нажатия на кнопку "Sp"
        $("#smp_t").click(function(){
	        if ($('.smp').css('display') == 'none') {
			$('.smp').fadeIn();
	                $('#smp_t').text('☺ ☑');
	        } else {
			$('.smp').fadeOut();
	                $('#smp_t').text('☺ ☐');
	        }
        });
	// Новый спойлер
	$(".spoiler-title").live('click', function(){
		var $e = $(".spoiler-body", $(this).closest(".spoiler")).eq(0);
		if ($e.css('display') == 'none') {
			$e.css("display", "block");
		} else {
			$e.hide("normal");
		}
	});
	hideImg();
	loadPP2();
	// Вверх-вниз
        $("#up-switch").click(function(){
                $("body,html").animate({"scrollTop":0},1000);
        });
        $("#down-switch").click(function(){
                $("body,html").animate({"scrollTop":$(document).height()},1000);
        });
});
// Despoil-link
$(function(){
    $("#despoil").click(function(){
        $(".spoiler-body").each(function(){
            var el=$(this);
            if(el.css('display') == 'none'){
                el.css('display', 'block');
            }
        })
    });
});