BaseViewer = require './base-viewer'

module.exports =
class AtomPdfViewer extends BaseViewer
  _forwardSync = (view, texFile, line) ->
    view?.forwardSync?(texFile, line)

  _getActivePaneItem = (pdfFile, opts = {}) ->
    for item of atom.workspace.getPaneItems()
      if item.filePath is pdfFile
        unless opts.keepFocus
          pane = atom.workspace.paneForItem(item)
          pane.activate()
          pane.activateItem(item)
        return item

  _open = (pdfFile, opts = {}, callback = null) ->
    if opts.keepFocus
      cb = callback
      current = atom.workspace.getActivePaneItem()
      callback = (view) ->
        pane = atom.workspace.paneForItem(current)
        pane.activate()
        pane.activateItem(current)
        cb(view)
  
    atom.workspace.open(
      pdfFile,
      split: 'right',
      activatePane: not opts.keepFocus
      searchAllPanes: true
    ).done callback

  forwardSync: (pdfFile, texFile, line, col, opts = {}) ->
    view = _getActivePaneItem pdfFile
    return _forwardSync view, texFile, line if view?

    @ltConsole.addContent "Opening #{pdfFile}"
    _open pdfFile, opts, (view) -> _forwardSync(view, texFile, line)

  viewFile: (pdfFile, opts = {}) ->
    @ltConsole.addContent "Opening #{pdfFile}"
    _open pdfFile, opts
