handleDeviceOrientation = ({alpha, gamma, beta}) ->
  # Meteor.call('handleDeviceOrientation', {alpha, beta, gamma})

  # alpha: rotation around z-axis
  # beta: front back motion
  # gamma: left to right
  
  window.svg.select('.alpha')
    .transition()
    .text("alpha: " + alpha)

  window.svg.select('.beta')
    .transition()
    .text("beta: " + beta)

  window.svg.select('.gamma')
    .transition()
    .text("gamma: " + gamma)


handleDeviceMotion = ({accelerationIncludingGravity, interval}) ->

  # for server side handling of devicemotion
  # Meteor.call('handleDeviceMotion', {accelerationIncludingGravity, rotationRate})

  a = accelerationIncludingGravity
  # a.x runs side-to-side across the mobile phone screen, or the laptop keyboard and is positive towards the right side
  # a.y runs front-to-back across the mobile phone screen or the laptop keyboard and is positive towards as it moves away from you
  # a.z comes straight up out of the mobile phone screen or the laptop keyboard and is positive as it moves up

  window.svg.select('.x')
    .transition().duration(interval)
    .text("x acceleration: " + a.x)

  window.svg.select('.y')
    .transition().duration(interval)
    .text("y acceleration: " + a.y)

  window.svg.select('.z')
    .transition().duration(interval)
    .text("z acceleration: " + a.z)

  value = _.reduce(_.map(_.values(a), Math.abs), ((a, b) -> return a * b), 1)

  window.svg.select('circle')
    .transition().duration(interval)
    .attr("r", value)

  console.log(value)

handleResize = ->
  console.log(window.innerWidth, window.innerHeight)
  window.svg
    .attr("width", window.innerWidth)
    .attr("height", window.innerHeight)

  window.svg.selectAll('text')
    .attr("x", -> return window.innerWidth / 2.0)

  window.svg.select('circle')
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

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 20)
    .attr('class', 'x')

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 40)
    .attr('class', 'y')

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 60)
    .attr('class', 'z')

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 80)
    .attr('class', 'alpha')

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 100)
    .attr('class', 'beta')

  window.svg.append('text')
    .attr('text-anchor', 'middle')
    .attr("y", 120)
    .attr('class', 'gamma')

  window.svg.append('circle')

  handleResize!

  stub = { accelerationIncludingGravity: { x: 4, y: 4, z: 4 }}
  handleDeviceMotion(stub)

Template.gyro.destroyed = ->
  window.removeEventListener("deviceorientation", handleDeviceOrientation, true)
  window.removeEventListener("devicemotion", handleDeviceMotion, true)
  window.removeEventListener("resize", handleResize, true)

