extensions [nw rnd]
breed [persons person]

undirected-link-breed [relationship-links relationship-link]
undirected-link-breed [friend-links friend-link]


persons-own [qualities
preferences ;set
gender ; set
similarity-count ; set
potential-partner ; needs to be done
partner-link-preference ; set
current-partner]


globals [ all-qualities
  probabilities-qualities
  hop-preference-probabalities
  hop-relations
  inverse-probabilites-qualities
  partner-probabalities
  partners ]

to setup
  clear-all
  reset-ticks
  if Initially-distribute-friends = "Erdos"[nw:generate-random persons friend-links population erdos-connection-prob-friends [ set color yellow ]]
  if Initially-distribute-friends = "Strogatz" [nw:generate-watts-strogatz persons friend-links population strogatz-connections-friends strogatz-rewire-prob-friend [ set color yellow ]]
  if Initially-distribute-relationships = "Erdos"[nw:generate-random persons relationship-links population erdos-conenction-prob-relationship [ set color red ]]
  if Initially-distribute-relationships = "Strogatz" [nw:generate-watts-strogatz persons relationship-links population strogatz-connection-relationship strogatz-rewire-prob-relationship [ set color red]]
  repeat 100 [ layout-spring persons links 0.2 5 2]

  ask persons [ if count relationship-link-neighbors > 1 [let choosen one-of relationship-link-neighbors ask my-relationship-links  [die ] create-relationship-link-with choosen[set color red] ]]

  ask persons [set preferences  list set-pref set-pref  ]
  ask persons [set preferences lput set-pref preferences] ; giving everyone 3 preferences
  ask persons [set qualities  list set-qualities set-qualities  ]
  ask persons [set qualities lput set-qualities qualities ] ; giving everyone 3 qualities

  ask persons [set partner-link-preference set-hop-pref] ; how far away or close in terms of degree does this person want to date
  ask persons [set similarity-count random 100]
  ask persons [set potential-partner nobody]
  ask persons [ifelse one-of relationship-link-neighbors = nobody [set current-partner nobody][set current-partner one-of relationship-link-neighbors]]


  ask persons [set shape "dot"]
  ask friend-links[set color yellow]
  ask relationship-links[set color red]


  ask persons [ifelse random 100 < percentage-males [set gender "male" set color blue][ set gender "female" set color pink]]
  ask persons [setxy random-xcor random-ycor]

end

to go
 move-and-make-friends  ; done
 search ; use puesdocode to complete
 date ; use puesdocode
 ditch ; done
 get-on-off-social-media ; done
 ask relationship-links [set color red]
 tick
 if ticks >= 200[stop
 nw:set-context turtles links
 nw:save-graphml "example.graphml"]
end

to search ; doesnt work as planned try to fix please
  ask persons [

   let my-prefs preferences
   let my-qualities qualities
   let my-gender gender
   set potential-partner one-of other (nw:turtles-in-radius partner-link-preference) with [(length (intersect my-prefs qualities) > intersection-required) and gender != my-gender and (length (intersect my-qualities preferences) > intersection-required)]
  ]

end


to date ; date the person you are most compatible with from your potential partners if you arent dating anyone
  ask persons [
    if current-partner = nobody [
    let my-sim similarity-count
    let rishta-qabool false
    if potential-partner != nobody[
    ask potential-partner [if abs(similarity-count - my-sim) < similarity-req[set rishta-qabool true]]
    if rishta-qabool [ set current-partner potential-partner create-relationship-link-with current-partner [set color red]
    ask current-partner[set current-partner myself]]
    ]
  ]
  ]
end


to ditch ; probablisticlity break up with the person/friend
  ask persons [if random-float 100 < leave-friend-prob [ if  one-of friend-links != nobody [ask one-of friend-links [die]]]]
  ask persons [if random-float 100 < leave-partner-prob[ if  one-of relationship-links != nobody [
    ask current-partner [
      set current-partner nobody
    ]
    set current-partner nobody
    ask one-of relationship-links [die ]]]]
end

to get-on-off-social-media
  ask persons [if random-float 100 < join-social-media-prob[
    hatch-persons 1 [
      set qualities  list set-qualities set-qualities
      set qualities lput set-qualities qualities
      set preferences list set-pref set-pref
      set preferences lput set-pref preferences
      set potential-partner nobody
      ifelse random 100 < percentage-males [set gender "male" set color blue][ set gender "female" set color pink]
      set similarity-count random 100
      set partner-link-preference set-hop-pref]]]
   ask persons[if random-float 100 < leave-social-media-prob [die] ]
end


to move-and-make-friends
  ask persons [fd random 3 lt random 3]
  ask persons [if count other persons in-radius 1 != 0 and random 100 < make-friend-prob [create-friend-links-with n-of 1 other persons in-radius 1[set color yellow]] ]

end

to-report set-pref
   set probabilities-qualities [0.132 0.155 0.17 0.009 0.11 0.07 0.112 0.119 0.039 0.047 0.039]
   set all-qualities ["Looks" "Humor" "Kindness" "Race" "Education" "Similar-Hobbies"
"Similar-Worldviews" "Similar Age"  "Social-Standing" "Financial-Stability" "High number ofprevious partners"]
  report first rnd:weighted-one-of-list (map list all-qualities probabilities-qualities ) last
end


to-report set-qualities
  set probabilities-qualities [0.132 0.155 0.17 0.009 0.11 0.07 0.112 0.119 0.039 0.047 0.039]
  set inverse-probabilites-qualities[0.03101157816340214 0.026409860113348924 0.024079578338641664 0.454836479729898 0.03721389379608257 0.05847897596527261 0.036549359978295386 0.034399397626630954 0.10496226455305341 0.08709634718232091 0.10496226455305341]
  set all-qualities ["Looks" "Humor" "Kindness" "Race" "Education" "Similar-Hobbies"
    "Similar-Worldviews" "Similar Age"  "Social-Standing" "Financial-Stability" "High number ofprevious partners"]

  if distribute-qualities = "same as preferences"[report first rnd:weighted-one-of-list (map list all-qualities probabilities-qualities ) last]
  if distribute-qualities = "inverse of preferences"[report first rnd:weighted-one-of-list (map list all-qualities inverse-probabilites-qualities ) last]
  if distribute-qualities = "randomly"[report one-of all-qualities]
end


to-report set-hop-pref
  set hop-preference-probabalities [0.26 0.33 0.29 0.105]
  set hop-relations [ 1 3 2 4]
  report first rnd:weighted-one-of-list (map list hop-relations hop-preference-probabalities ) last
end

to-report intersect [ a b ]
   set a sort a
   set b sort b
   let c []
   while [ not (empty? a or empty? b ) ]
   [ if-else first a < first b
     [ set a but-first a
     ]
     [ if-else first a > first b
       [ set b but-first b
       ]
       [ set c fput first a c
         set a but-first a
         set b but-first b
       ]
     ]
   ]
   report ( c)
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
786
587
-1
-1
17.21212121212121
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
73
63
136
96
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
72
103
135
136
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
182
191
215
percentage-males
percentage-males
1
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
16
142
188
175
population
population
1
1000
77.0
1
1
NIL
HORIZONTAL

CHOOSER
16
234
190
279
distribute-qualities
distribute-qualities
"same as preferences" "inverse of preferences" "randomly"
0

SLIDER
13
398
199
431
leave-social-media-prob
leave-social-media-prob
0
2
0.51
0.01
1
NIL
HORIZONTAL

SLIDER
15
436
187
469
leave-partner-prob
leave-partner-prob
0
100
0.0
1
1
NIL
HORIZONTAL

CHOOSER
789
92
983
137
Initially-distribute-relationships
Initially-distribute-relationships
"Strogatz" "Erdos"
0

SLIDER
788
140
1036
173
erdos-conenction-prob-relationship
erdos-conenction-prob-relationship
0
1
0.24
0.01
1
NIL
HORIZONTAL

SLIDER
916
48
1088
81
make-friend-prob
make-friend-prob
0
100
13.0
1
1
NIL
HORIZONTAL

SLIDER
917
10
1089
43
leave-friend-prob
leave-friend-prob
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
18
362
190
395
join-social-media-prob
join-social-media-prob
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
16
283
188
316
intersection-required
intersection-required
0
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
16
320
188
353
similarity-req
similarity-req
0
100
92.0
1
1
NIL
HORIZONTAL

CHOOSER
1056
87
1217
132
initially-distribute-friends
initially-distribute-friends
"Strogatz" "Erdos"
0

SLIDER
1055
136
1278
169
erdos-connection-prob-friends
erdos-connection-prob-friends
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1058
176
1264
209
strogatz-rewire-prob-friend
strogatz-rewire-prob-friend
0
1
0.32
0.01
1
NIL
HORIZONTAL

SLIDER
792
178
1030
211
strogatz-rewire-prob-relationship
strogatz-rewire-prob-relationship
0
1
0.08
0.01
1
NIL
HORIZONTAL

SLIDER
1059
216
1268
249
strogatz-connections-friends
strogatz-connections-friends
0
population / 2
0.0
1
1
NIL
HORIZONTAL

SLIDER
790
223
1018
256
strogatz-connection-relationship
strogatz-connection-relationship
0
population / 2
3.0
1
1
NIL
HORIZONTAL

MONITOR
801
262
918
307
Total Relationships
count relationship-links
17
1
11

MONITOR
926
262
1032
307
Total Friendships
count friend-links
17
1
11

PLOT
802
311
1002
461
Total Relationships
ticks
no. of relationships
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -8053223 true "" "plot count relationship-links"

PLOT
1013
309
1213
459
Total Friendships
ticks
no. of friends
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -4079321 true "" "plot count friend-links"

PLOT
803
469
1003
619
Total Population
ticks
no. of people
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot count persons"

PLOT
1015
471
1215
621
Total Lonely People
ticks
no. of lonely people
0.0
200.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -11783835 true "" "plot (count turtles with [current-partner = nobody])"

MONITOR
1040
262
1142
307
Total Population
count persons
17
1
11

MONITOR
1147
262
1236
307
Lonely People
count persons with [current-partner = nobody]
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="leave-partner">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percentage-males">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribute-qualities">
      <value value="&quot;same as preferences&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Initial-connections">
      <value value="140"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="879"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="leave-social-media-prob">
      <value value="0.32"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@
