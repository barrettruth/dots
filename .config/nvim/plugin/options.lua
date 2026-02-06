local o, opt = vim.o, vim.opt

o.autowrite = true

o.breakindent = true

o.cursorline = true

o.cmdheight = 0
o.conceallevel = 0

opt.diffopt:append('linematch:60')

o.expandtab = true

o.exrc = true
o.secure = true

opt.foldcolumn = 'auto:1'
opt.signcolumn = 'no'

opt.fillchars = {
    eob = ' ',
    vert = '│',
    diff = '╱',
}

opt.iskeyword:append('-')

o.laststatus = 3

o.linebreak = true

o.list = true
opt.listchars = {
    space = ' ',
    trail = '·',
    tab = '  ',
}

opt.matchpairs:append('<:>')

o.number = true
o.relativenumber = true

opt.path:append('**')

o.scrolloff = 8

o.shiftwidth = 2

opt.shortmess:append('acCIs')

o.showmode = false

o.showtabline = 0

o.spellfile = (vim.env.XDG_DATA_HOME or (vim.env.HOME .. '/.local/share'))
    .. '/nvim/spell.encoding.add'

o.splitkeep = 'screen'

o.splitbelow = true
o.splitright = true

o.swapfile = false

o.termguicolors = true

o.undodir = (vim.env.XDG_DATA_HOME or (vim.env.HOME .. '/.local/share'))
    .. '/nvim/undo'
o.undofile = true

o.updatetime = 50

o.winborder = 'single'
o.winbar = ''

o.wrap = false
