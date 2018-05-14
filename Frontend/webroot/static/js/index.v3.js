var pokemonIndex = 0
var gymIndex = 0

$( document ).ready(function() {
    $('input[name="gym-search"], input[name="pokemon-search"]').bind('input', function () {
        searchAjax($(this))
    })
    $("#submit-raid").click(function() {
         submit()
    });
	$("#skip").click(function() {
		window.location.href = "/"
	});
});

function searchAjax(field) { // eslint-disable-line no-unused-vars
    var term = field.val()
    var type = field.data('type')
    var index = 0
    if (type == 'gym') {
        gymIndex = gymIndex + 1
        index = gymIndex
    } else if (type == 'pokemon') {
        pokemonIndex = pokemonIndex + 1
        index = pokemonIndex
    }
    if (term !== '') {
        $.ajax({
               url: 'search',
               type: 'POST',
               timeout: 300000,
               dataType: 'json',
               cache: false,
               data: {
                   'action': type,
                   'term': term
               }
               }).done(function (data) {
                       if (data && (type == 'gym' && gymIndex == index) || (type == 'pokemon' && pokemonIndex == index)) {
	                       var par = field.parent()
	                       var sr = par.find('.search-results')
	                       sr.html('')
                       data.forEach(function (element) {
                                    var html = '<li class="search-result">' +
                                        '<div class="left-column" onClick="selectPokemon(' + element.id + ',\''+type+'\');"' +
                                        'data-type = "' + type + '" data-id="' + element.id + '">'
                                    if (element.url !== '') {
                                    html += '<span style="background:url(' + element.url + ') no-repeat;" class="i-icon" ></span>'
                                    }
                                    html += '<div class="cont"><span class="name" >' + element.name + '</span>'
                                    if(sr.hasClass('reward-results')){
                                    html += '<span>&nbsp;-&nbsp;</span> <span class="reward" style="font-weight:bold">' + element.reward + '</span>'
                                    }
                                    html += '</div></div>'
                                    html += '</li>'
                                    sr.append(html)
                                    })
                       }
                       })
    } else {
	    var par = field.parent()
	    var sr = par.find('.search-results')
	    sr.html('')
    }
}

function selectPokemon(id, type) {
	var arraySelected = document.getElementsByClassName("left-column-selected");
	var arrayNormal = document.getElementsByClassName("left-column");

	for(var i = (arraySelected.length - 1); i >= 0; i--) {
	    if ($(arraySelected[i]).attr("data-type") == type) {
		    arraySelected[i].className = "left-column";
	    }
	}

	for(var i = (arrayNormal.length - 1); i >= 0; i--) {
		if ($(arrayNormal[i]).attr("data-type") == type && $(arrayNormal[i]).attr("data-id") == id) {
			arrayNormal[i].className = "left-column-selected";
		}
	}
}

function submit() {
    var mon = 0
    var gym = -1
    var id = $(document.getElementById("id")).attr("value")

	var arraySelected = document.getElementsByClassName("left-column-selected");
	for(var i = (arraySelected.length - 1); i >= 0; i--) {
		if ($(arraySelected[i]).attr("data-type") == "pokemon") {
			mon = $(arraySelected[i]).attr("data-id")
		}
		if ($(arraySelected[i]).attr("data-type") == "gym") {
			gym = $(arraySelected[i]).attr("data-id")
		}
	}

    var pokemonElement = document.getElementById("pokemon-search")
    if (pokemonElement != null) {
        if (mon == 0) {
            alert("Pokémon Benötigt!")
            return
        } else if (mon < 0 || mon > 386) {
            alert("Pokémon Falsch!")
            return
        }
    }
    
	if (gym == -1) {
		alert("Arena Benötigt!")
    } else if (id == null) {
		alert("Fehler! Bitte Lade die Seite neu!")
	} else {
		$.post( "/submit", { id: id, mon: mon, gym: gym } )
		.done(function( data ) {
			window.location.href = "/"
		});
	}
}
