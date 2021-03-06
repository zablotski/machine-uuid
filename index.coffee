
{exec}  = require("child_process")
os      = require("os")

uuid      = undefined

uuidRegex = /\w{8}\-\w{4}\-\w{4}\-\w{4}\-\w{12}/

defaultUuidFolder = __dirname

module.exports = (cb, filepath)->

  if filepath then defaultUuidFolder = filepath

  if uuid then return setImmediate ()->cb(uuid)
  platFormSpecific = {
    'darwin' : osxUuid,
    'win32'  : winUuid,
    'win64'  : winUuid,
    'linux'  : linuxUuid
  }
  platformGetUuid = platFormSpecific[os.platform()]
  if platformGetUuid
    platformGetUuid (err, id)->
      if (err)
        defaultUuid cb
      else
        cb(uuid = id)
  else
    defaultUuid cb

linuxUuid = (cb)->
  try
    fs = require("fs")
    uuid = fs.readFile "/var/lib/dbus/machine-id", (err, content)->
      if content  # clean, add - and remove whitespace
        uuid = content.toString().replace /\s+/, ''
        if (not /\-/.test uuid) and uuid.length > 20
          uuid = uuid[0...8] + '-' + uuid[8...12] + '-' + uuid[12...16] + '-' + uuid[16...20] + '-' + uuid[20...]

      cb(err, if content then uuid)
  catch e
    defaultUuid cb

osxUuid = (cb)->
  exec "ioreg -rd1 -c IOPlatformExpertDevice", (err, stdout, stderr)->
    if err then return cb(err)
    for line in stdout.split("\n") when /IOPlatformUUID/.test(line) and uuidRegex.test(line)
      return cb(null, uuidRegex.exec(line)[0])
    cb(new Error("No match"))

winUuid = (cb)->
  exec "wmic CsProduct Get UUID", (err, stdout, stderr)->
    if err then return cb(err)
    for line in stdout.split("\n") when uuidRegex.test(line)
      return cb(null, uuidRegex.exec(line)[0])
    cb(new Error("No match"))

defaultUuid = (cb)->
  path = require "path"
  fs = require "fs"
  f = path.resolve(defaultUuidFolder, '.nodemid')
  if fs.existsSync(f)
    cb(fs.readFileSync(f).toString())
  else
    id = require('node-uuid').v1()
    fs.writeFileSync(f, id);
    cb(id)

