/* 
Kalman filter ported to javascript
 Copyright (C) 2013 Michael Williams

Original code: https://github.com/TKJElectronics/KalmanFilter/blob/master/Kalman.h
 Copyright (C) 2012 Kristian Lauszus, TKJ Electronics. All rights reserved.
 
 This software may be distributed and modified under the terms of the GNU
 General Public License version 2 (GPL2) as published by the Free Software
 Foundation and appearing in the file GPL2.TXT included in the packaging of
 this file. Please note that GPL2 Section 2[b] requires that all works based
 on this software must also be made publicly available under the terms of
 the GPL2 ("Copyleft").
 
 Contact information
 -------------------
 
 Kristian Lauszus, TKJ Electronics
 Web      :  http://www.tkjelectronics.com
 e-mail   :  kristianl@tkjelectronics.com
 */

class @Kalman

  (@angle=0, @qAngle=0.001, @qBias=0.003,  @rMeasure=0.03) ->
    @bias = 0
    @p = [[], []]
    @p[0][0] = 0
    @p[0][1] = 0
    @p[1][0] = 0
    @p[1][1] = 0
    @rate = 0

  compute: (newAngle, newRate, dt) ->
    console.log(@rate, @angle, newRate, newAngle)
    # KasBot V2  -  Kalman filter module - http://www.x-firm.com/?page_id=145
    # Modified by Kristian Lauszus
    # See my blog post for more information: http://blog.tkjelectronics.dk/2012/09/a-practical-approach-to-kalman-filter-and-how-to-implement-it
                    
    # Discrete Kalman filter time update equations - Time Update ("Predict")
    # Update xhat - Project the state ahead
    /* Step 1 */
    @rate = newRate - @bias
    @angle += dt * @rate
    
    # Update estimation error covariance - Project the error covariance ahead
    /* Step 2 */
    @p[0][0] += dt * (dt*@p[1][1] - @p[0][1] - @p[1][0] + @qAngle)
    @p[0][1] -= dt * @p[1][1]
    @p[1][0] -= dt * @p[1][1]
    @p[1][1] += @qBias * dt
    
    # Discrete Kalman filter measurement update equations - Measurement Update ("Correct")
    # Calculate Kalman gain - Compute the Kalman gain
    /* Step 4 */
    S = @p[0][0] + @rMeasure
    /* Step 5 */
    K = []
    K[0] = @p[0][0] / S
    K[1] = @p[1][0] / S
    
    # Calculate angle and bias - Update estimate with measurement zk (newAngle)
    /* Step 3 */
    y = newAngle - @angle
    /* Step 6 */
    @angle += K[0] * y
    @bias += K[1] * y
    
    # Calculate estimation error covariance - Update the error covariance
    /* Step 7 */
    @p[0][0] -= K[0] * @p[0][0]
    @p[0][1] -= K[0] * @p[0][1]
    @p[1][0] -= K[1] * @p[0][0]
    @p[1][1] -= K[1] * @p[0][1]
    
    return {@angle, @rate}