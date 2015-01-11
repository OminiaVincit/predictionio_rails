# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
	  
this.select_kind = (kind) ->
  $('[name="color"]').empty()
  if kind is "vegetable"
    colors = ["","green", "red"]
  else
    colors = ["","yellow", "pink", "purple"]
 
  for col in colors
    $('[name="color"]').append($('<option>').val(col).text(col))
 
this.select_color = ->
  $('[name="item"]').empty()
  col = $('[name="color"]').val()
 
  switch col
    when "green"
      items = ["Cabbage","Lettuce", "Cucumber"]
    when "red"
      items = ["Carrot","Tomatoes"]
    when "yellow"
      items = ["Lemon","Banana", "Pineapple"]
    when "pink"
      items = ["Peach"]
    when "purple"
      items = ["Grape"]
    else
      alert 'no selected'
      return
 
  for item in items
    $('[name="item"]').append($('<option>').val(item).text(item))
	
