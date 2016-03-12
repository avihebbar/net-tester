express = require 'express'
conf = require 'config'
netMon = require './lib/network-monitor'

app = express();

app.get '/getCurrentReadings', (req,res)=>
  readings = netMon.getCurrentReadings()
  res.status(200).json({
    readings : readings
  })

netMon.init();
console.log "App listening to #{conf.get('port')}"
app.listen(conf.get('port'))