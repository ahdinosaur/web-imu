window.debug = true

class IMU
  (@frequency=100) ->
    @orientation = {
      alpha: null, # rotation around z-axis
      beta: null, # front back motion
      gamma: null, # left to right
    }

    @motion = {
      x: null, # runs side-to-side across the mobile phone screen, or the laptop keyboard and is positive towards the right side
      y: null, # runs front-to-back across the mobile phone screen or the laptop keyboard and is positive towards as it moves away from you
      z: null, # comes straight up out of the mobile phone screen or the laptop keyboard and is positive as it moves up
      alpha: null,
      beta: null,
      gamma: null,
    }

  handleDeviceOrientation: ({alpha, beta, gamma}) ~>
    @orientation.alpha = alpha
    @orientation.beta = beta
    @orientation.gamma = gamma

  handleDeviceMotion: ({accelerationIncludingGravity, interval, rotationRate}) ~>
    @motion.x = accelerationIncludingGravity.x
    @motion.y = accelerationIncludingGravity.y
    @motion.z = accelerationIncludingGravity.z
    @motion.alpha = rotationRate.alpha
    @motion.beta = rotationRate.beta
    @motion.gamma = rotationRate.gamma

  create: ->
    if window.DeviceOrientationEvent
      window.addEventListener("deviceorientation", @handleDeviceOrientation, true)
    else
      console.error("deviceorientation not supported!")

    if window.DeviceMotionEvent
      window.addEventListener("devicemotion", @handleDeviceMotion, true)
    else
      console.error("devicemotion not supported!")

    window.addEventListener("resize", @handleResize, true)

  destroy: ->
    window.removeEventListener("deviceorientation", @handleDeviceOrientation, true)
    window.removeEventListener("devicemotion", @handleDeviceMotion, true)
    window.removeEventListener("resize", @handleResize, true)

  render: ->
    # if in debug mode, show raw data
    if window.debug
      $('.alphaPos').html("alpha position: " + @orientation.alpha)
      $('.betaPos').html("beta position: " + @orientation.beta)
      $('.gammaPos').html("gamma position: " + @orientation.gamma)
      $('.xAccel').html("x acceleration: " + @motion.x)
      $('.yAccel').html("y acceleration: " + @motion.y)
      $('.zAccel').html("z acceleration: " + @motion.z)
      $('.alphaRot').html("alpha rotation: " + @motion.alpha)
      $('.betaRot').html("beta rotation: " + @motion.beta)
      $('.gammaRot').html("gamma rotation: " + @motion.gamma)

    # absolute value of each x, y, z value multiplied by each other
    #value = _.reduce(_.map(_.values(a), Math.abs), ((a, b) -> return a * b), 1)
    # absolute value of each x, y, z value added to each other
    a = [@motion.x, @motion.y, @motion.z]
    value = _.reduce(_.map(a, Math.abs), ((a, b) -> return a + b), 0)
    # account for gravity
    value -= 9.81
    # cap at 0
    value = (if (value < 0) then 0 else value)
    # make more pronounced
    value = Math.pow(value, 3)

    gyro = d3.select('.gyro')
      .transition().duration(@frequency)
      .style('background-size', value + ' ' + value)

  start: ->
    self = this
    @animation = setInterval((->
      self.render!
    ), @frequency)

imu = new IMU()

handleResize = ->

  # use jQuery for auto prefixing
  $('.gyro').css('perspective', Math.max(window.innerWidth, window.innerHeight)*2)

  if window.debug
    # use jQuery to show resize data
    $('.screenW').html("screen width: " + window.innerWidth)
    $('.screenH').html("screen height: " + window.innerHeight)

Template.gyro.created = ->
  imu.create!

Template.gyro.rendered = ->
  handleResize!
  imu.start!

  if not window.debug
    $('.data').css('display', 'none')

Template.gyro.destroyed = ->
  imu.destroy!