; amoeba game
; copyright 2014 Galen Wilkerson gjwilkerson@gmail.com

; one/multiple players tries to move amoeba to surround and eat other bacteria

; use mouse, click and drag amoeba arms to stretch/move amoeba

; implementation

; rules:
; surface must remain contiguous
; fluid must have constant volume, except after eating

breed [skins skin]
breed [bodies body]
breed [bacteria bacterium]
breed [organelles organelle]

globals [
chemical-max amoeba-size amoeba-center-x amoeba-center-y amoeba-diameter amoeba-diameter-original score diffusion-rate evaporation-rate
spring-constant
spring-length
repulsion-constant
]

bacteria-own [health alive?]

patches-own [
  chemical ; how much blob material is on the patch
]

to setup
  clear-all
  diffuse pcolor .3
  ;set amoeba-size 160
  set diffusion-rate 100
  set evaporation-rate 13
  set score 0
  set amoeba-size 50
  create-amoeba
  create-germs
  ;set diffusion-rate 10
  ;set evaporation-rate 2
  set chemical-max 3
  set amoeba-center-x mean [xcor] of organelles
  set amoeba-center-y mean [ycor] of organelles
  set amoeba-diameter max [distancexy amoeba-center-x amoeba-center-y] of organelles
  show amoeba-diameter
  set amoeba-diameter-original world-width / 6
  set spring-constant 0.06
  set repulsion-constant 0.45
  set spring-length 0.67
  layout
end

to go
  layout
  handle-mouse
  ask organelles [
    set color yellow
  ]
  set amoeba-center-x mean [xcor] of organelles
  set amoeba-center-y mean [ycor] of organelles
  set amoeba-diameter max [distancexy amoeba-center-x amoeba-center-y] of organelles
  if amoeba-diameter = 0 [ set amoeba-diameter 10 ]
  move-bacteria
  eval-bacteria-health
  tick
  if score = 3 [show "YOU WON!!!"]
  if ticks >= 1000
    [show "GAME OVER" stop]
end

to handle-mouse ; use mouse-distance - don't let people drag very far
  if mouse-down? [
    let amoeba-center-patch patch amoeba-center-x amoeba-center-y
    let candidate min-one-of organelles [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 10 [
      
      ;watch candidate
      let mouse-distance [distancexy mouse-xcor mouse-ycor] of amoeba-center-patch 
      
      while [mouse-down?] [
        ;; If we don't force the display to update, the user won't
        ;; be able to see the turtle moving around.
        display
        ;; The SUBJECT primitive reports the turtle being watched.
        ask candidate [ 
          setxy mouse-xcor mouse-ycor 
          ;every 1 [set color yellow]
          set color red
          set shape "circle"
        ]
      
        set mouse-distance [distancexy mouse-xcor mouse-ycor] of amoeba-center-patch
        if mouse-distance > world-width / 2 [
          ask candidate [
            set color green  
            set shape "circle"
            show "Be carefulllll...."
          ]
        ] ;  DON'T GET TOO STRETCHED OUT 
      ]
      ask candidate [set color yellow   set shape "circle 2"]
      if mouse-distance > world-width / 2 [ask candidate [die]] ;  DON'T GET TOO STRETCHED OUT 
   ]
  ]
end

; an amoeba is made of:
; body
; organelles (circular bodies)
; create the "insides" of the amoeba
to create-amoeba
  create-bodies 1 [ 
    let x-location ( random world-width ) - world-width / 2
    let y-location ( random world-height ) - world-height / 2
;    while [ abs (x-location - world-width / 2) < 100 or abs (y-location - world-height / 2) < 100 ] [
;      set x-location random-xcor
;      set y-location random-ycor
;    ]
    setxy x-location y-location
    set hidden? true  

    hatch-bodies amoeba-size 
     [
       set hidden? true
       while [count bodies in-radius .5 > 1] [
         rt random 360
         fd 1 
       ]       
     ]
     
     hatch-organelles 5 [
       set hidden? false
       set shape "circle 2" 
       set color yellow
       set size 2 + random 3
       while [count turtles in-radius 1 > 1] [
         rt random 29 - 15
         fd 4 
       ]  
     ]   
  ]
  
  ; connect things up so that the organelles can be used to move the thing around
  ask bodies [
    create-link-with one-of other bodies [ set hidden? true ]
    create-link-with one-of organelles [set hidden? true]
  ]

end

to create-germs
  create-bacteria 3 [ 
    setxy amoeba-center-x amoeba-center-y 
    fd random world-width / 2 + 20; move forward
    set shape "monster" 
    set color red
    set size 4 + random 2
    set health 10
    set alive? true
  ]
end

; move bacteria randomly away from amoeba
; if touched by amoeba, start to change color until dead
; turn upside down when dead
; if touching open area, wriggle free
to move-bacteria
  ask bacteria 
  [
    if alive? [ ; if too close to amoeba center or any blue patches nearby...
      ifelse ( distancexy amoeba-center-x amoeba-center-y < 30 or any? patches with [pcolor > 100] in-radius 30 ) 
      [  ;run away!!
        downhill pcolor
        fd random 5 
      ]
      [ ; move randomly
        rt random 360
        fd random 5
      ]
    ]
  ]
end

; if touched by the amoeba, start to lose health & change color
; if health = 0, turn upside down and stop moving, gradually decay
to eval-bacteria-health
  
  ask bacteria [
    ifelse alive?
    [  
      set health health - ( ( [ chemical ] of patch-here ) / chemical-max ) ; how much blue and how thinly spread is the amoeba here
      set color scale-color red ( health / 2 ) 0 10
      if health <= 0 
      [ 
        set alive? false
        set color lime
        set shape "monster-dead"
        set score score + 1
      ]
    ]
    [ ; dead, decompose
      if color > 60 
      [
        set color color - .1
      ]    
    ]
  ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end

to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 3 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    ; let factor sqrt count turtles
    ;; numbers here are arbitrarily chosen for pleasing appearance
    ; layout-spring turtles links (1 / factor) (7 / factor) (1 / factor)
    layout-spring bodies links spring-constant spring-length repulsion-constant
    ;display  ;; for smooth animation
  ]
;  ;; don't bump the edges of the world
;  let x-offset max [xcor] of bodies + min [xcor] of bodies
;  let y-offset max [ycor] of bodies + min [ycor] of bodies
;  ;; big jumps look funny, so only adjust a little each time
;  set x-offset limit-magnitude x-offset 0.1
;  set y-offset limit-magnitude y-offset 0.1
;  ask bodies [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
  ;ask patches [ ifelse any? bodies-on self [set pcolor blue] [set pcolor black] ]
  ask organelles [
    ask patches in-radius 1
     [set chemical chemical-max * amoeba-diameter-original / amoeba-diameter
     ;set pcolor blue
     ]
  ]
  
  ask bodies
  [ ask patches in-radius 3
      [ set chemical chemical-max * amoeba-diameter-original / amoeba-diameter
       ;set pcolor blue 
       ] 
  ]

  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    set pcolor scale-color blue chemical 0.1 5 ] 
end

@#$#@#$#@
GRAPHICS-WINDOW
300
13
1114
488
100
55
4.0
1
8
1
1
1
0
1
1
1
-100
100
-55
55
1
1
1
ticks

CC-WINDOW
5
502
1123
597
Command Center
0

BUTTON
10
103
77
136
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
89
103
152
136
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

TEXTBOX
6
211
299
350
To play: \nClick and drag organelles, \nsurround and eat bacteria!\n- You have 1000 ticks!\n- Hints: Digestive juices are diluted when you spread out.\nBe careful not to stretch too far!
15
62.0
1

MONITOR
199
101
257
154
NIL
score
17
1
13

TEXTBOX
12
31
263
81
Amoeba game\nYou are an Amoeba!!!
20
104.0
1

@#$#@#$#@
WHAT IS IT?
-----------
The Amoeba Game by Galen Wilkerson (C) 2007
gwilkers@uvm.edu


HOW IT WORKS
------------
Click and drag organelles (yellow circles) to move.

Your digestive juices are less effective when you are spread-out!

Try to trap and eat bacteria by surrounding them (difficult).
Bacteria become very hard to see when they are almost dead.

HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hex
false
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

monster
false
0
Polygon -7500403 true true 75 150 90 195 210 195 225 150 255 120 255 45 180 0 120 0 45 45 45 120
Circle -16777216 true false 165 60 60
Circle -16777216 true false 75 60 60
Polygon -7500403 true true 225 150 285 195 285 285 255 300 255 210 180 165
Polygon -7500403 true true 75 150 15 195 15 285 45 300 45 210 120 165
Polygon -7500403 true true 210 210 225 285 195 285 165 165
Polygon -7500403 true true 90 210 75 285 105 285 135 165
Rectangle -7500403 true true 135 165 165 270

monster-dead
false
0
Polygon -13840069 true false 75 150 90 105 210 105 225 150 255 180 255 255 180 300 120 300 45 255 45 180
Circle -16777216 true false 165 180 60
Circle -16777216 true false 75 180 60
Polygon -13840069 true false 225 150 285 105 285 15 255 0 255 90 180 135
Polygon -13840069 true false 75 150 15 105 15 15 45 0 45 90 120 135
Polygon -13840069 true false 210 90 225 15 195 15 165 135
Polygon -13840069 true false 90 90 75 15 105 15 135 135
Rectangle -13840069 true false 135 30 165 135
Polygon -2674135 true false 225 225 165 165 150 180 225 255 240 240
Polygon -2674135 true false 225 195 165 255 150 240 225 165 240 180
Polygon -2674135 true false 75 225 135 165 150 180 75 255 60 240
Polygon -2674135 true false 75 195 135 255 150 240 75 165 60 180

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
