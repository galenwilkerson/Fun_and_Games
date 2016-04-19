; climber!
; author: Galen Wilkerson
; gjwilkerson@gmail.com
; copyright 2007

breed [bricks brick]
breed [body-parts body-part]

patches-own [
  vertical-angle ; ranges from "positive" 45 deg to "negative" 90 
  ;vertical-angle-cos ; pre-compute cosine of vertical angle 
]

body-parts-own
[ ;fx     ;; x-component of force vector
  ;fy     ;; y-component of force vector
  vx     ;; x-component of velocity vector
  vy     ;; y-component of velocity vector
  xc     ;; real x-coordinate (in case particle leaves world)
  yc     ;; real y-coordinate (in case particle leaves world)
  ;r-sqrd ;; square of the distance to the ground
  attached? ;; boolean telling whether attached to wall or not
]

globals
[ 
  first-move?
  left-hand
  right-hand
  left-foot
  right-foot
  head
  right-elbow
  left-elbow
  right-knee
  left-knee
  hips
  shoulders
  knees
  elbows
  falling?
  center-of-mass-x
  center-of-mass-y
  all-but-head
  energy-level
  resting?
  appendages
  all-but-appendages
  hands
  feet
  score
  num-bricks
  speed
]

to reset
  clear-all
  reset-timer
  set first-move? true
  set resting? false
  setup-body
  set num-bricks 30
  setup-bricks
  set score 0
  set speed 0.05
  set energy-level 10
  ask patches [

    set vertical-angle ( random-normal 90 270 ) - 90   
     
  ]
  repeat 30 [
    diffuse vertical-angle .9
  ]
  
  ask patches [
    ;set vertical-angle-cos cos (vertical-angle)
    set pcolor scale-color wall-color ( vertical-angle * 2) -90 45
  ]
end

to play
  
  handle-mouse
  ifelse first-move? [ ; the first move, can't fall
    
  ]
  [ ; not the first move, can fall 
    check-body
    
    ifelse falling? [
      fall
      stop
      reset
    ] 
    [
      layout
    ]
    
  ]
  set center-of-mass-x mean [xcor] of body-parts  
  set center-of-mass-y mean [ycor] of body-parts  
  if energy-level > 10 [
    set energy-level 10
  ]
  ask patches [
    set pcolor scale-color wall-color (vertical-angle * 2) -90 45 
  ]
  move-bricks
  do-plots
  
end

to setup-body
  set-default-shape body-parts "circle 2"
  set falling? false
  
  create-body-parts 1 [] 
  create-body-parts 4 [ fd 5 create-link-with body-part 0 ]
  create-body-parts 1 [ fd 5 create-link-with body-part 1]
  create-body-parts 1 [ fd 5 create-link-with body-part 3]
  create-body-parts 2 [fd 5 create-link-with body-part 4 ]
  create-body-parts 1 [ fd 5 create-link-with body-part 7]
  create-body-parts 1 [ fd 5 create-link-with body-part 8]

  set head body-part 2
  set left-hand body-part 6
  set right-hand body-part 5
  set left-foot body-part 9
  set right-foot body-part 10
  set hips body-part 4
  set shoulders body-part 0
  set right-elbow body-part 1
  set left-elbow body-part 3
  set right-knee body-part 8
  set left-knee body-part 7
    
  set all-but-head (turtle-set body-part 0 body-part 1 body-part 3 body-part 4 body-part 5 body-part 6 body-part 7 body-part 8 body-part 9 body-part 10 )
  set appendages (turtle-set right-hand left-hand right-foot left-foot)
  set all-but-appendages (body-parts with [member? self appendages != true])
  set hands (turtle-set right-hand left-hand)
  set feet (turtle-set right-foot left-foot)
  set knees (turtle-set right-knee left-knee)
  set elbows (turtle-set right-elbow left-elbow)
  
   
  ask body-parts [
    setxy 0 min-pycor + 5
    set attached? false
  ]
  ask appendages [
    set attached? true
    set color 26
  ]

  ask head [
    set heading 0 
    fd 3
    set shape "face happy" 
    set size 4
    set color white
  ] 
  ask left-hand [
    set heading -45
    fd 5
    set shape "hand-left"
    set size 3
    
  ]
  ask right-hand [
    set heading 45
    fd 5
    set shape "hand-right"
    set size 3
  ]
  
  ask right-foot [
    set heading 135 
    ;fd 5
    set shape "foot-right"
    set size 3
    set heading 0
  ]
  
  ask left-foot [
    set heading -135
    ;fd 5
    set shape "foot-left"
    set size 3
    set heading 0    
  ]
  
;  repeat 50 [
;    layout
;  ]

  ask links [
    set color climber-color
    set thickness 1
  ]

  set center-of-mass-x mean [xcor] of body-parts  
  set center-of-mass-y mean [ycor] of body-parts  
  display

end

to setup-bricks
  set-default-shape bricks "tile stones"
  create-bricks num-bricks [
    set size 3
    set heading 180
    setxy random-xcor random-ycor
    set color brick-color
  ]

end

to move-bricks ; move everything down when climber near the middle
  if center-of-mass-y > 0 [
    ask bricks [
      ifelse can-move? 1 [
        fd speed ;*  [vertical-angle-cos] of patch-here )
        set score score + speed
        if num-bricks > 10 [
          set num-bricks 30 - timer / 10 ;  gradually reduce the number of bricks.  
        ]
      ]
      [ 
      if count bricks <= num-bricks [    
          hatch-bricks 1 [
            setxy random-xcor max-pycor
          ]
        ]
        die               
      ]
    ]
    ask body-parts [
      if attached? [
        ifelse can-move? 1 [
          set heading 180
          fd  speed ; * [vertical-angle-cos] of patch-here)
        ]
        [
          set attached? false
        ]
      ]
    ]
  ]
end

to fall
   
  ask head [set shape "face sad"]
  show "uh oh"
  wait 1
  while [abs (center-of-mass-y - min-pycor ) > 2] [
     __layout-magspring body-parts links 0.3 4 1 .10 5 false
    set center-of-mass-x mean [xcor] of body-parts  
    set center-of-mass-y mean [ycor] of body-parts  
    show "aaaaaaaaaaaa!!"
  ]
  wait 1
  show "thud"
  clear-links
  repeat 50 [
     __layout-magspring body-parts links 0.3 4 1 0 0 false
  ]
  clear-all
  reset
end

to layout
  ;layout-spring ( body-parts with [attached? = false] ) links 0.2 5 1
  
  
  ; head, shoulders, torso, hands pulled up
  ; joints, hands, pulled upward, feet pulled down
 
  ; if resting, let everything unattached hang
  ; if not resting
  ;    if foot attached, raise knee and hips
  ;    else
  ;    
 
  ifelse resting? [ ; let everything hang,  except lift attached knees
    let all-but-knees (body-parts with [member? self knees != true])
    __layout-magspring (all-but-knees with [attached? = false] ) links 0.2 5 1 .05 5 false
    __layout-magspring (knees with [attached? = false] ) links 0.2 5 1 .05 1 false
  ]
  [ ; if not resting
    ;    if foot attached, raise knee and hips
    let limbs-to-lift (turtle-set head shoulders hands)
    if [attached?] of right-foot [
      set limbs-to-lift (turtle-set limbs-to-lift hips right-knee)
    ]
    if [attached?] of left-foot [
      set limbs-to-lift (turtle-set limbs-to-lift hips left-knee)
    ]
    
    ; lift some limbs
    __layout-magspring ( limbs-to-lift with [attached? = false] ) links 0.2 5 1 .05 1 false
    
    ; just layout others
    let limbs-not-to-lift ( all-but-head with [member? self limbs-to-lift != true])

    ; lay them out
    ;layout-spring (turtle-set head) links  0.2 5 1
    __layout-magspring (limbs-not-to-lift with [attached? = false] ) links 0.2 5 1 .01 5 false
    ;__layout-magspring ( limbs-to-lift ) with [attached? = false] ) links 0.2 5 1 0 0 false
  ]
  
  
;  if [attached?] of right-foot 
;    let limbs-to-lift (turtle-set shoulders elbows hands head hips)
;  ]
;   [attached?] of left-foot [
;  [
;    let limbs-to-lift (turtle-set shoulders elbows hands head)
;  ]
;    __layout-magspring ( (turtle-set shoulders elbows hands head hips) with [attached? = false] ) links 0.2 5 1 .05 1 false
;  
;  __layout-magspring ( (turtle-set feet knees) with [attached? = false] ) links 0.2 5 1 1 0 false
  
end

to handle-mouse ; use mouse-distance - don't let people drag very far
  let mouse-pressed? false
  let candidate min-one-of appendages [distancexy mouse-xcor mouse-ycor]
  if mouse-down? and 
    ( candidate = right-hand or candidate = left-hand or 
    candidate = right-foot or candidate = left-foot)
    [
    set mouse-pressed? true
    if first-move? [ ; if we just started, reset the timer
      reset-timer
    ]
    set first-move? false ; not the first move of the game
    set resting? false  ; stop resting
    set candidate min-one-of appendages [distancexy mouse-xcor mouse-ycor]
    if [distancexy mouse-xcor mouse-ycor] of candidate < 5 [
         
      while [mouse-down?] [
        ;; If we don't force the display to update, the user won't
        ;; be able to see the body-part moving around.
        display
        ;; The SUBJECT primitive reports the body-part being watched.
        ask candidate [ 
            if distancexy center-of-mass-x center-of-mass-y < 20 [
              setxy mouse-xcor mouse-ycor 
              ;every 1 [set color yellow]
              ;set color red
            ]
          ]
        layout
      ]
    ]
  ]
  if mouse-pressed? = true [
    let candidate-brick min-one-of bricks [distancexy mouse-xcor mouse-ycor]
    ifelse [distancexy [xcor] of candidate [ycor] of candidate] of candidate-brick < 5 [ ; attached
      ;show candidate-brick
      ask candidate [
        setxy ([xcor] of candidate-brick) ([ycor] of candidate-brick )
        set attached? true
      ]
    ]
    [ ; not attached
      ask candidate [ 
        set attached? false
      ]
    ]
  ]  
end

; check for at least one hand attached at all times
; if not, fall!
to check-body
  let hands-on-holds count hands with [attached? = true] 
  if  hands-on-holds = 0 [
    set falling? true
  ]
  ; reduce energy when doing hard moves
  ifelse resting? = true [
    set energy-level energy-level + 0.0001
  ] 
  [
    ; if no feet on holds, tiring
    let feet-on-holds count feet with [attached? = true]
    if feet-on-holds = 0 [
      set energy-level energy-level - .001
      show "Beefy arms!"
      if hands-on-holds = 1 ; twice as tiring if only one hand on hold
      [
        set energy-level energy-level - .001
      ]
    ]
    
    if [ycor] of left-foot > center-of-mass-y + 5 [  ; heel hook 
      set energy-level energy-level - .001
      show "Left heel-hook!! Awesoome!"
    ]
    if [ycor] of right-foot > center-of-mass-y + 5 [ 
      set energy-level energy-level - .001
      show "Right heel-hook!! Gnarley!"
    ]
    
    ; check how much we're leaning, the more we lean, the more energy we lose     
    let lean abs (( [link-heading] of link [who] of shoulders [who] of hips ) - 180)
    ifelse lean < 45 [
      set energy-level energy-level + .0001 / lean
    ]
    [
      show "Lay back!"
      set energy-level energy-level - .00001 * lean
    ]
  ]
  
  ; change the face and head color based on energy level
  
  ifelse energy-level > 6.6 [
    ask head [ 
      set shape "face happy"
    ]
  ]
  [
    ifelse energy-level > 3.3 [
      ask head [ 
        set shape "face neutral"
      ]
    ]
    [
      ask head [
        set shape "face sad"
      ]
      if energy-level <= 0 [
        set falling? true
      ]
    ]
  ]
  ask head [
    set color scale-color red energy-level 0 10
  ]
  
  ; randomly detach (slip) off of holds
  if resting? = false and allow-slips [
    ask appendages [
      if random 10000 < 1 [
        set attached? false
      ]
    ]
  ]
end

to do-plots
  set-current-plot "energy level"
  set-current-plot-pen "energy"
  plot energy-level
end

to rest
  set resting? true
end
@#$#@#$#@
GRAPHICS-WINDOW
234
11
742
540
40
40
6.15
1
10
1
1
1
0
0
0
1
-40
40
-40
40
0
0
1
ticks

CC-WINDOW
5
554
1146
649
Command Center
0

BUTTON
28
49
95
82
NIL
reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
104
49
167
82
NIL
play
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
17
103
217
253
energy level
time
energy
0.0
10.0
0.0
10.0
true
false
PENS
"default" 1.0 0 -16777216 true
"energy" 1.0 0 -16777216 true

MONITOR
18
258
75
311
NIL
score
0
1
13

BUTTON
523
469
586
502
NIL
rest
NIL
1
T
OBSERVER
NIL
Z
NIL
NIL

TEXTBOX
844
224
1059
499
CLIMBER\nRace the clock, climb as high as you can!  Click and drag hands and feet to holds. Watch out for slipping!\n\nHints: Watch your hands and your body position.  Rest to regain energy, or if you get stuck.
18
104.0
1

SWITCH
785
113
911
146
allow-slips
allow-slips
0
1
-1000

SLIDER
785
32
957
65
brick-color
brick-color
0
140
64.2
.1
1
NIL
HORIZONTAL

SLIDER
785
70
957
103
wall-color
wall-color
5
135
115
10
1
NIL
HORIZONTAL

SLIDER
965
31
1137
64
climber-color
climber-color
0
140
24
1
1
NIL
HORIZONTAL

@#$#@#$#@
 Climber!
 author: Galen Wilkerson
 gwilkers@uvm.edu
 copyright 2007


HOW IT WORKS
------------

Climb the wall.
Click and drag hands and feet to holds.
You are against the clock - fewer holds appear the longer you take to climb.

You will fall if:
- Energy gets too low.
- You let go with both hands.

You can rest (hold space bar) to regain energy.

You can do cool moves, such as a heel hook (foot above hands) 
or hang with one hand, but these use precious energy!

Hint: Sometimes you can stretch farther if you let go of a hold!


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
Polygon -955883 true false 0 150 0 105 15 105 0 30 30 60 30 0 60 30 75 0 105 15 105 0 120 0 135 15 150 0 180 15 195 0 195 15 240 0 225 30 270 15 255 45 285 45 270 75 300 75 285 90
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Polygon -955883 true false 0 150 0 105 15 105 0 60 45 60 45 0 90 15 105 0 120 15 180 0 195 15 270 0 225 30 270 15 255 60 285 45 270 75 300 75 285 90
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Polygon -955883 true false 15 135 0 75 30 75 15 30 60 45 60 0 90 15 135 0 165 15 195 0 210 30 270 0 240 45 285 30 270 75 285 75 270 90
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

foot-left
true
0
Circle -7500403 true true 176 147 90
Circle -7500403 true true 57 196 48
Circle -7500403 true true 48 155 30
Circle -7500403 true true 27 175 22
Circle -7500403 true true 21 198 22
Circle -7500403 true true 27 222 22
Circle -7500403 true true 46 239 20
Polygon -7500403 true true 210 227 75 240 78 195 196 156

foot-right
true
0
Circle -7500403 true true 34 147 90
Circle -7500403 true true 195 196 48
Circle -7500403 true true 222 155 30
Circle -7500403 true true 251 175 22
Circle -7500403 true true 257 198 22
Circle -7500403 true true 251 222 22
Circle -7500403 true true 234 239 20
Polygon -7500403 true true 90 227 225 240 222 195 104 156

hand-left
false
0
Rectangle -7500403 true true 75 30 105 90
Rectangle -7500403 true true 120 15 150 75
Rectangle -7500403 true true 180 30 210 90
Rectangle -7500403 true true 240 120 270 180
Polygon -7500403 true true 30 135 15 135 45 195 75 195 45 135 15 135
Polygon -7500403 true true 75 90 90 150 120 150 105 90 75 90
Polygon -7500403 true true 120 75 135 135 165 135 150 75 120 75
Polygon -7500403 true true 270 180 240 240 210 240 240 180 270 180
Polygon -7500403 true true 180 90 180 150 210 150 210 90 180 90
Circle -7500403 true true 75 180 120
Polygon -7500403 true true 45 75 45 135 15 135 15 75

hand-right
false
0
Rectangle -7500403 true true 195 30 225 90
Rectangle -7500403 true true 150 15 180 75
Rectangle -7500403 true true 90 30 120 90
Rectangle -7500403 true true 30 120 60 180
Polygon -7500403 true true 270 135 285 135 255 195 225 195 255 135 285 135
Polygon -7500403 true true 225 90 210 150 180 150 195 90 225 90
Polygon -7500403 true true 180 75 165 135 135 135 150 75 180 75
Polygon -7500403 true true 30 180 60 240 90 240 60 180 30 180
Polygon -7500403 true true 120 90 120 150 90 150 90 90 120 90
Circle -7500403 true true 105 180 120
Polygon -7500403 true true 255 75 255 135 285 135 285 75

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

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

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

legs
5.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Polygon -7500403 true true 75 15 75 270 75 285 135 300 210 285 210 15 150 0 90 15

@#$#@#$#@
