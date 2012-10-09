/********
 * Arduino Pong
 * By Pete Lamonica
 *  modified by duboisvb
 * A simple implementation of Pong on the Arduino using a TV for output.
 *
 */

#include <TVout.h>
#include "hw_config.h"


#define PADDLE_HEIGHT 10
#define PADDLE_WIDTH 1

#define RIGHT_PADDLE_X (TV.horz_res()-4)
#define LEFT_PADDLE_X 2

#define IN_GAMEA 0 //in game state - draw constants of the game box
#define IN_GAMEB 0 //in game state - draw the dynamic part of the game
#define IN_MENU 1 //in menu state
#define GAME_OVER 2 //game over state
#define LEFT_SCORE_X (TV.horz_res()/2-15)
#define RIGHT_SCORE_X (TV.horz_res()/2+10)
#define SCORE_Y 4

#define MAX_Y_VELOCITY 6
#define PLAY_TO 7

#define LEFT 0
#define RIGHT 1

TVout TV;
unsigned char x, y;

boolean button1Status = false;
// boolean button2Status = false;

int wheelOnePosition = 0;
int wheelTwoPosition = 0;
int rightPaddleY = 0;
int leftPaddleY = 0;
unsigned char ballX = 0;
unsigned char ballY = 0;
char ballVolX = 2;
char ballVolY = 2;

int leftPlayerScore = 0;
int rightPlayerScore = 0;

int frame = 0;
int state = IN_MENU;

void processInputs()
{
	wheelOnePosition = analogRead(WHEEL_ONE_PIN);
	wheelTwoPosition = analogRead(WHEEL_TWO_PIN);
	button1Status = (digitalRead(BUTTON_ONE_PIN) == LOW);

	//  button2Status = (digitalRead(BUTTON_TWO_PIN) == LOW);
	if ((button1Status == true) && (state == GAME_OVER))
	{
		drawMenu();
	}
//   button1Status = (digitalRead(BUTTON_ONE_PIN));

//cdubois
//  Serial.println(BUTTON_ONE_PIN);
// Serial.println(BUTTON_TWO_PIN);
//   delay(500);
	// Serial.println(button1Status);
	// Serial.println(button2Status);
	//  Serial.println(wheelOnePosition);
	//  Serial.println(wheelTwoPosition);
	//  delay(1000);

}

void drawGameScreen()
{
	//  TV.clear_screen();
	//draw right paddle
	rightPaddleY = ((wheelOnePosition / 8) * (TV.vert_res() - PADDLE_HEIGHT))
			/ 128;
	x = RIGHT_PADDLE_X;
	for (int i = 0; i < PADDLE_WIDTH; i++)
	{
		TV.draw_line(x + i, rightPaddleY, x + i, rightPaddleY + PADDLE_HEIGHT,
				1);
	}

	//draw left paddle
	leftPaddleY = ((wheelTwoPosition / 8) * (TV.vert_res() - PADDLE_HEIGHT))
			/ 128;
	x = LEFT_PADDLE_X;
	for (int i = 0; i < PADDLE_WIDTH; i++)
	{
		TV.draw_line(x + i, leftPaddleY, x + i, leftPaddleY + PADDLE_HEIGHT, 1);
	}

	//draw score
	TV.print_char(LEFT_SCORE_X, SCORE_Y, '0' + leftPlayerScore);
	TV.print_char(RIGHT_SCORE_X, SCORE_Y, '0' + rightPlayerScore);

	//draw ball
	TV.set_pixel(ballX, ballY, 2);
}

//player == LEFT or RIGHT
void playerScored(byte player)
{
	if (player == LEFT)
		leftPlayerScore++;
	if (player == RIGHT)
		rightPlayerScore++;

	//check for win
	if (leftPlayerScore == PLAY_TO || rightPlayerScore == PLAY_TO)
	{
		state = GAME_OVER;
	}

	ballVolX = -ballVolX;
	ballVolY = 2;
	ballY = TV.vert_res() / 2;
}

void drawBox()
{
	TV.clear_screen();

	//draw net
	for (int i = 1; i < TV.vert_res() - 4; i += 6)
	{
		TV.draw_line(TV.horz_res() / 2, i, TV.horz_res() / 2, i + 3, 1);
	}
	// had to make box a bit smaller to fit tv 
	TV.draw_line(0, 0, 0, 95, 1);  // left
	TV.draw_line(0, 0, 126, 0, 1); // top
	TV.draw_line(126, 0, 126, 95, 1); // right
	TV.draw_line(0, 95, 126, 95, 1); // bottom

	state = IN_GAMEB;
}

void drawMenu()
{
	x = 0;
	y = 0;
	char volX = 3;
	char volY = 3;
	TV.clear_screen();
	TV.select_font(_8X8);
	TV.print_str(10, 5, "Arduino Pong");
	TV.select_font(_5X7);
	TV.print_str(22, 35, "Press Button");
	TV.print_str(30, 45, "To Start");

	delay(1000);
	while (!button1Status)
	{
		processInputs();
		TV.delay_frame(3);
		if (x + volX < 1 || x + volX > TV.horz_res() - 1)
			volX = -volX;
		if (y + volY < 1 || y + volY > TV.vert_res() - 1)
			volY = -volY;
		if (TV.get_pixel(x + volX, y + volY))
		{
			TV.set_pixel(x + volX, y + volY, 0);

			if (TV.get_pixel(x + volX, y - volY) == 0)
			{
				volY = -volY;
			}
			else if (TV.get_pixel(x - volX, y + volY) == 0)
			{
				volX = -volX;
			}
			else
			{
				volX = -volX;
				volY = -volY;
			}
		}
		TV.set_pixel(x, y, 0);
		x += volX;
		y += volY;
		TV.set_pixel(x, y, 1);
	}

	TV.select_font(_5X7);
	state = IN_GAMEA;
}

void setup()
{
	//   Serial.begin(9600);
	x = 0;
	y = 0;
	TV.start_render(_PAL); //for devices with only 1k sram(m168) use TV.begin(_NTSC,128,56)

	ballX = TV.horz_res() / 2;
	ballY = TV.vert_res() / 2;

	pinMode(BUTTON_ONE_PIN, INPUT);      // sets the digital pin as output
}

void pong_tone(int frequency)
{
	tone(AUDIO_PIN, frequency);
}

void loop()
{
	processInputs();

	if (state == IN_MENU)
	{
		drawMenu();
	}
	if (state == IN_GAMEA)
	{
		drawBox();
	}

	if (state == IN_GAMEB)
	{
		bool scored = false;

		if (frame % 2 == 0)
		{ //every n frame
			ballX += ballVolX;
			ballY += ballVolY;

			// change if hit top or bottom
			if (ballY <= 1 || ballY >= TV.vert_res() - 1)
			{
				ballVolY = -ballVolY;
				pong_tone(2100);
			}

			// test left side for wall hit    
			if (ballVolX
					< 0&& ballX == LEFT_PADDLE_X+PADDLE_WIDTH-1 && ballY >= leftPaddleY && ballY <= leftPaddleY + PADDLE_HEIGHT){
				ballVolX = -ballVolX;
				ballVolY += 2 * ((ballY - leftPaddleY) - (PADDLE_HEIGHT / 2))
						/ (PADDLE_HEIGHT / 2);
				pong_tone(2000);
			}

			// test right side for wall hit     
			if (ballVolX
					> 0&& ballX == RIGHT_PADDLE_X && ballY >= rightPaddleY && ballY <= rightPaddleY + PADDLE_HEIGHT)
			{
				ballVolX = -ballVolX;
				ballVolY += 2 * ((ballY - rightPaddleY) - (PADDLE_HEIGHT / 2))
						/ (PADDLE_HEIGHT / 2);
				pong_tone(2000);
			}

			//limit vertical speed
			if (ballVolY > MAX_Y_VELOCITY)
				ballVolY = MAX_Y_VELOCITY;
			if (ballVolY < -MAX_Y_VELOCITY)
				ballVolY = -MAX_Y_VELOCITY;

			// Scoring
			if (ballX <= 1)
			{
				playerScored(RIGHT);
				scored = true;
			}
			if (ballX >= TV.horz_res() - 1)
			{
				playerScored(LEFT);
				scored = true;
			}
		}

//    if(button1Status) Serial.println((int)ballVolX);

		drawGameScreen();

		if (scored)
		{
			for (int i = 0; i < 10; i++)
			{
				pong_tone(500 - (20 * i));
				TV.delay_frame(1);
			}
		}
	}

	if (state == GAME_OVER)
	{
		drawGameScreen();
		TV.select_font(_8X8);
		TV.print_str(29, 25, "GAME");
		TV.print_str(68, 25, "OVER");
		while (!button1Status)
		{
			processInputs();
			delay(50);
		}
		TV.select_font(_5X7); //reset the font
		//reset the scores
		leftPlayerScore = 0;
		rightPlayerScore = 0;
		state = IN_MENU;
	}

	TV.delay_frame(1);
	noTone(AUDIO_PIN);
	if (++frame == 60)
		frame = 0; //increment and/or reset frame counter
}