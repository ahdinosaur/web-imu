Meteor.methods({
  log: (s) ->
    console.log("log", s)
  handleDeviceOrientation: ({alpha, gamma, beta}) ->
    console.log("orientation", alpha, gamma, beta)
  handleDeviceMotion: ({accelerationIncludingGravity, rotationRate}) ->
    console.log("motion", accelerationIncludingGravity, rotationRate)
})
