Spine = require('spine')
List  = require("models/list")
Setting = require("models/setting")
Keys  = require("utils/keys")

class ListTitle extends Spine.Controller

  elements:
    "h1": "listName"
    ".buttons .trash": "deleteButton"
    ".buttons .sort": "sortButton"

  events:
    "keyup h1": "rename"
    "keypress h1": "preventer"
    "click .buttons a": "menuClick"

  constructor: ->
    super
    List.bind "changeList", @render

  # Display listname
  render: (@list) =>
    @listName.text @list.name

    # Disables contenteditable on noneditable lists
    if @list.permanent
      @listName.removeAttr("contenteditable")
      @deleteButton.fadeOut(150)
    else
      @listName.attr("contenteditable", true)
      @deleteButton.fadeIn(150)

    # Er, not sure but it detects complted and all
    if @list.disabled
      @sortButton.fadeOut(150)
    else
      @sortButton.fadeIn(150)

  # This is fired on keyup when a list is renamed
  rename: (e) ->
    List.current.updateAttribute("name", @listName.text())

  # Prevents the enter key
  preventer: (e) ->
    e.preventDefault() if e.which is Keys.ENTER

  # Handles menu buttons
  menuClick: (e)->

    switch e.currentTarget.className
      when "trash"
        # Yes, I know DRY. But FUCK YOU.
        if Setting.get "confirmDelete"
          # Shows the Modal
          $(".modal.delete").show(0).addClass "show"

          # Deletes if yes is clicked
          $(".modal.delete .true").on("click", =>
            @list.destroy()
            $(".modal.delete .false").trigger "click"
            $(".modal.delete .true").off "click"
          )

          # Fancy animates away if not
          $(".modal.delete").on("click", (e) =>
            if $(e.target).hasClass("false") or $(e.target).hasClass("modal")
              $(".modal.delete").removeClass "show"
              setTimeout ( ->
                $(".modal.delete").hide 0
              ), 350
              $(".modal.delete").off "click"
          )
        else
          @list.destroy()

      when "email" then @log "emailing"
      when "print" then window.print()
      when "share" then @log "sharing"
      when "sort"  then Setting.toggleSort()

module.exports = ListTitle