window.debug = true

class @IMU
  (@dt=100) ->
    @orientation = {
      alpha: 0, # rotation around z-axis
      beta: 0, # front back motion
      gamma: 0, # left to right
    }

    @motion = {
      x: 0, # runs side-to-side across the mobile phone screen, or the laptop keyboard and is positive towards the right side
      y: 0, # runs front-to-back across the mobile phone screen or the laptop keyboard and is positive towards as it moves away from you
      z: -9.81, # comes straight up out of the mobile phone screen or the laptop keyboard and is positive as it moves up
      alpha: 0,
      beta: 0,
      gamma: 0,
    }

    @alphaKalman = new Kalman()
    @betaKalman = new Kalman()
    @gammaKalman = new Kalman()

  handleDeviceOrientation: ({alpha, beta, gamma}) ~>
    @orientation.alpha = alpha || 0
    @orientation.beta = beta || 0
    @orientation.gamma = gamma || 0

  handleDeviceMotion: ({accelerationIncludingGravity, interval, rotationRate}) ~>
    @motion.x = accelerationIncludingGravity.x || 0
    @motion.y = accelerationIncludingGravity.y || 0
    @motion.z = accelerationIncludingGravity.z || 0
    @motion.alpha = rotationRate.alpha || 0
    @motion.beta = rotationRate.beta || 0
    @motion.gamma = rotationRate.gamma || 0

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

  tick: ->

    @alphaKalman.compute(@orientation.alpha, @motion.alpha, @dt)
    @betaKalman.compute(@orientation.beta, @motion.beta, @dt)
    @gammaKalman.compute(@orientation.gamma, @motion.gamma, @dt)

    orientation = {
      alpha: @alphaKalman.angle
      beta:  @betaKalman.angle
      gamma: @gammaKalman.angle
    }

    motion = {
      alpha: @alphaKalman.rate
      beta:  @betaKalman.rate
      gamma: @gammaKalman.rate
    }

    # if in debug mode, show raw data
    if window.debug
      $('.xAccel').html("x acceleration: " + @motion.x)
      $('.yAccel').html("y acceleration: " + @motion.y)
      $('.zAccel').html("z acceleration: " + @motion.z)
      $('.alphaPos').html("alpha position: " + orientation.alpha)
      $('.betaPos').html("beta position: " + orientation.beta)
      $('.gammaPos').html("gamma position: " + orientation.gamma)
      $('.alphaRot').html("alpha rotation: " + motion.alpha)
      $('.betaRot').html("beta rotation: " + motion.beta)
      $('.gammaRot').html("gamma rotation: " + motion.gamma)

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
      .transition().duration(@dt)
      .style('background-size', value + ' ' + value)

  start: ->
    self = this
    @animation = setInterval((->
      self.tick!
    ), @dt)

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