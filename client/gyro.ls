window.debug = true

handleDeviceOrientation = ({alpha, gamma, beta}) ->
  # for server side handling of deviceorientation
  Meteor.call('handleDeviceOrientation', {alpha, beta, gamma})

  # alpha: rotation around z-axis
  # beta: front back motion
  # gamma: left to right

  if window.debug
    # use jQuery to show orientation data
    $('.alphaPos').html("alpha position: " + alpha)
    $('.betaPos').html("beta position: " + beta)
    $('.gammaPos').html("gamma position: " + gamma)

  # use jQuery for auto prefixing of css3 transforms
  $('.display').css("transform",
    #"rotateZ(" + ( alpha - 180 ) + "deg)" +
    "rotateX(" + ( -beta ) + "deg)" +
    "rotateY(" + ( -gamma ) + "deg)"
  )

handleDeviceMotion = ({accelerationIncludingGravity, interval, rotationRate}) ->

  # for server side handling of devicemotion
  Meteor.call('handleDeviceMotion', {accelerationIncludingGravity, rotationRate})

  a = accelerationIncludingGravity
  # a.x runs side-to-side across the mobile phone screen, or the laptop keyboard and is positive towards the right side
  # a.y runs front-to-back across the mobile phone screen or the laptop keyboard and is positive towards as it moves away from you
  # a.z comes straight up out of the mobile phone screen or the laptop keyboard and is positive as it moves up

  r = rotationRate
  # TODO add description of rotation rate

  if window.debug
    # use jQuery to show motion data
    $('.xAccel').html("x acceleration: " + a.x)
    $('.yAccel').html("y acceleration: " + a.y)
    $('.zAccel').html("z acceleration: " + a.z)
    $('.alphaRot').html("alpha rotation: " + r.alpha)
    $('.betaRot').html("beta rotation: " + r.beta)
    $('.gammaRot').html("gamma rotation: " + r.gamma)

  #value = _.reduce(_.map(_.values(a), Math.abs), ((a, b) -> return a * b), 1)
  value = _.reduce(_.map(_.values(a), Math.abs), ((a, b) -> return a + b), 0)
  # account for gravity
  value -= 9.81
  # make more pronounced
  value = Math.pow(value, 3)
  # cap at 0
  value = (if (value < 0) then 0 else value)

  gyro = d3.select('.gyro')
    .transition().duration(interval)
    .style('background-size', value + ' ' + value)

handleResize = ->

  # use jQuery for auto prefixing
  $('.gyro').css('perspective', Math.max(window.innerWidth, window.innerHeight)*2)

  if window.debug
    # use jQuery to show resize data
    $('.screenW').html("screen width: " + window.innerWidth)
    $('.screenH').html("screen height: " + window.innerHeight)

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

Template.gyro.rendered = ->
  handleResize!
  handleDeviceOrientation({alpha: 0, beta: 0, gamma: 0})
  handleDeviceMotion({accelerationIncludingGravity: { x: 0, y: 0, z: -9.81 }})

  if not window.debug
    $('.data').css('display', 'none')

Template.gyro.destroyed = ->
  window.removeEventListener("deviceorientation", handleDeviceOrientation, true)
  window.removeEventListener("devicemotion", handleDeviceMotion, true)
  window.removeEventListener("resize", handleResize, true)

