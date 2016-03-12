conf = require 'config'
exec = require('child_process').exec

module.exports = {
  ping : (cb)->
    pingDetails = conf.get('ping_details');
    exec "ping -c #{pingDetails.count} #{pingDetails.destination}", (e, stdout, stderr)->
      return cb(e) if e?
      reg = new RegExp('([0-9]+)% packet loss')
      temp = reg.exec(stdout)
      packetLoss = RegExp.$1; 
      cb(null, packetLoss )

  speedTest : (cb)->
    exec './bin/speedtest-cli', (e, stdout, stderr)->
      return cb(e) if e?
      speed = []
      reg1 = new RegExp('Download: ([0-9]+\.[0-9]+)')
      reg2 = new RegExp('Upload: ([0-9]+\.[0-9]+)')
      
      temp = reg1.exec(stdout)
      speed.push(RegExp.$1)
      
      temp = reg2.exec(stdout)
      speed.push( RegExp.$1 )

      cb(null, speed )
}