handleDeviceOrientation = ({alpha, gamma, beta}) ->
  # alpha: rotation around z-axis
  # gamma: left to right
  # beta: front back motion
  # Meteor.call('handleDeviceOrientation', {alpha, gamma, beta})

handleDeviceMotion = ({accelerationIncludingGravity, interval}) ->
  # Meteor.call('handleDeviceMotion', {accelerationIncludingGravity, rotationRate})
  value = _.reduce(_.values(accelerationIncludingGravity),
                    ((a, b) -> return a * Math.abs(b)), 1)

  window.text
    .transition().duration(interval)
    .text(value)

  window.circle
    .transition().duration(interval)
    .attr("r", value)

  console.log(value)

handleResize = ->
  console.log(window.innerWidth, window.innerHeight)
  window.svg
    .attr("width", window.innerWidth)
    .attr("height", window.innerHeight)

  window.text
    .attr("x", -> return window.innerWidth / 2.0)
    .attr("y", 40)

  window.circle
    .attr("cx", -> return window.innerWidth / 2.0)
    .attr("cy", -> return window.innerHeight / 2.0)

Template.gyro.created = ->
  if window.DeviceOrientationEvent
    window.addEventListener("deviceorientation", handleDeviceOrientation, true)
  else
    console.error("deviceorientation not supported!")

  if window.DeviceMotionEvent
    window.addEventListener("devicemotion", handleDeviceMotion, true)
  else
    console.error("devicemotion not supported!")

  window.addEventListener("resize", handleResize, true)

  window.svg = d3.select('body').append('svg')

  window.text = window.svg
    .append('text')
    .attr('text-anchor', 'middle')

  window.circle = window.svg
    .append('circle')

  handleResize!

Template.gyro.destroyed = ->
  window.removeEventListener("deviceorientation", handleDeviceOrientation, true)
  window.removeEventListener("devicemotion", handleDeviceMotion, true)
  window.removeEventListener("resize", handleResize, true)
