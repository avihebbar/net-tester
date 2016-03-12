conf = require 'config'
exec = require('child_process').exec
async = require 'async'
monMethods = require './monitor-methods'
fs = require 'fs-extra'

readings = fs.readJsonSync('./data/readings.json')
currReadings = {}
networks = conf.get('networks')
for network in networks
  currReadings[network.name] = ({
    speed : {},
    packet_loss : 0
  })
  
updateReadingsForNetwork = (network, cb)=>
  async.parallel([
    (asyncCb)->
      monMethods.speedTest (e, speed)=>
        return asyncCb(e) if e?
        currReadings[network.name]['speed']['download'] = speed[0]
        currReadings[network.name]['speed']['upload'] = speed[1]
        asyncCb()
    ,(asyncCb)->
      monMethods.ping (e, packetLoss)=>
        return asyncCb(e) if e?
        currReadings[network.name]['packet_loss'] = packetLoss
        asyncCb()
  ],(e)->
    cb()
  )

changeNetwork = (network, cb)->
  console.log "Connecting to network : #{network.name}"
  exec "nmcli con up uuid #{network.uuid}", (e, stdout, stderr)->
    return cb(e) if e?
    return cb()

updateReadings = ()=>
  readings = fs.readJsonSync('./data/readings.json')
  async.eachSeries networks,
    (network, cb)=>
      changeNetwork network, (e)->
        if e?
          console.log "Unable to change network : #{network.name}"
          cb(e)
        updateReadingsForNetwork network, (e)->
          return cb(e);
    ,(e)->
      console.log currReadings
      readings.push(currReadings)
      fs.outputJsonSync('./data/readings.json', readings)

module.exports = {
  init : ()=>
    setInterval updateReadings, conf.get('poll_interval')*60*1000
  
  getCurrentReadings : ()->
    return readings
}






