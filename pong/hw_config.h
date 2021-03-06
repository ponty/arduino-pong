/*

   .--------------------------.
   |                          |          T
   |                          |         ---
   |            pin_button1   o---------o o----------.
   |                          |                      |
   |                          |                      |
   |                    GND   o----------------------'
   |  ARDUINO                 |
   |                    VCC   o---------.
   |                          |         |
   |                          |        .-.
   |             pin_wheel1   o------->| | 5k
   |                          |        | |
   |                          |        '-'
   |                          |         |
   |                    GND   o---------'
   |                          |
   |                          |
   |                    VCC   o---------.
   |                          |         |
   |                          |        .-.
   |             pin_wheel2   o------->| | 5k
   |                          |        | |
   |                          |        '-'
   |                          |         |
   |                    GND   o---------'
   |                          |
   |              pin_audio   o----------------------  audio
   |                    GND   o----------------------
   |                          |  1N4148        ___ 330
   |                     D8   o--------->|----|___|---.
   |                          |  1N4148        ___ 1k |
   |                     D9   o--------->|----|___|---------  video
   |                    GND   o-----------------------------
   '--------------------------'

 */

const int pin_wheel1 = 4; // analog
const int pin_wheel2 = 5; // analog
const int pin_button1 = 4;

const int pin_audio = 10;
