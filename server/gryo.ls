Meteor.methods({
  handleDeviceOrientation: ({alpha, gamma, beta}) ->
    console.log(alpha, gamma, beta)
  handleDeviceMotion: ({accelerationIncludingGravity, rotationRate}) ->
    console.log(accelerationIncludingGravity, rotationRate)
})
